import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:decibelio_app_web/models/observation_entry.dart';
import 'package:decibelio_app_web/services/auth_service.dart';
import 'package:decibelio_app_web/models/sensor_dto.dart';
import 'package:decibelio_app_web/services/conexion.dart';
import 'package:decibelio_app_web/services/facade/facade.dart';
import 'package:decibelio_app_web/services/facade/list/list_sensor_dto.dart';
import 'package:decibelio_app_web/utils/chromatic_noise.dart';
import 'package:decibelio_app_web/utils/show_dialog.dart';
import 'package:decibelio_app_web/views/dashboard/components/chart_ranges.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class SoundChartView extends StatefulWidget {
  const SoundChartView({super.key});

  @override
  State<SoundChartView> createState() => _SoundChartView();
}

class _SoundChartView extends State<SoundChartView> {
  final Conexion _conn = Conexion();
  final logger = Logger();
  Map<String, List<ObservationEntry>>? _historicalByFrame;

  String? selectedTemporal;
  String? selectedSensor;
  DateTime? startDate;
  DateTime? endDate;
  List<SensorDTO> _sensors = [];
  Timer? _pollingTimer;
  String? selectedText; // Texto seleccionado en minutos
  int? selectedNumericValue; // Valor numérico seleccionado en minutos

  // Mapa de opciones de intervalo (texto -> minutos)
  final Map<String, int> valuesMins = {
    "60 minutos": 60,
    "50 minutos": 50,
    "40 minutos": 40,
    "30 minutos": 30,
    "20 minutos": 20,
    "10 minutos": 10,
    "5 minutos": 5,
  };

  // Flags para habilitar panning / zoom en el gráfico
  late TransformationController _transformationController;

  // Historial de métricas (lista de pares: [“HH:mm”, valorDouble])
  List<(String, double)>? _metricsHistory;

  // Este flag solo para mostrar el diálogo la primera vez que se obtienen métricas
  bool _isInitialLoad = true;

  // Para saber si el usuario está logueado:
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    // 1) Inicialmente asumimos que solo “30 minutos” está permitido (para todos)
    selectedText = "30 minutos";
    selectedTemporal = "Diaria";
    selectedNumericValue = valuesMins[selectedText];

    // 2) Inicializamos fechas (hoy desde 00:00 hasta ahora)
    final now = DateTime.now();
    // 5 dias al dia anterior
    startDate = now.subtract(const Duration(days: 5));
    endDate = now;

    // 3) Configuramos controlador de transformaciones para el chart
    _transformationController = TransformationController();

    // 4) Cargamos los sensores y estado de autenticación
    _loadAuthStatus();
    loadSensorNames();
    _pollingTimer = Timer.periodic(
      const Duration(minutes: 5),
      (timer) => _reloadData(),
    );
  }

  /// Comprueba si hay usuario guardado en SharedPreferences
  Future<void> _loadAuthStatus() async {
    final userMap = await AuthService.getUser();
    setState(() {
      _isLoggedIn = (userMap != null);
    });
  }

  /// Obtiene la lista de sensores y selecciona el primero por defecto
  Future<void> loadSensorNames() async {
    Facade facade = Facade();
    ListSensorDTO sensorData = await facade.listSensorDTO();

    setState(() {
      _sensors = sensorData.data;
      if (_sensors.isNotEmpty) {
        selectedSensor = _sensors.first.externalId;
      }
    });

    // Una vez cargados los sensores, hacemos la primera recarga de métricas
    _reloadData();
  }

  void _showLoginRequiredDialog() {
    DialogUtils.showErrorDialog(context,
        'Debes iniciar sesión con tu correo institucional para seleccionar un intervalo diferente de 30 minutos.',
        title: 'Inicio de sesión requerido');
  }

  /// Lanza la consulta al backend para obtener métricas según el filtro actual
  void _reloadData({bool showConfirmation = false}) async {
    if (selectedSensor == null) {
      return;
    }

    try {
      if (selectedTemporal == 'Diaria') {
        if (selectedNumericValue == null) return;

        final data = {
          "sensorExternalId": selectedSensor,
          "intervalMinutes": selectedNumericValue,
        };

        final respuesta = await _conn.solicitudPost(
            'observation/sensor', data, Conexion.noToken);

        if (respuesta.status == 'SUCCESS' && respuesta.payload != null) {
          final observation =
              jsonDecode(respuesta.payload as String) as Map<String, dynamic>;

          setState(() {
            _metricsHistory = (observation['payload'] as List).expand((item) {
              return (item['observation'] as List).map((metric) {
                final horaString = metric['time'] as String;
                final valor = (metric['value'] as num).toDouble();
                final parts = horaString.split(":");
                final short = "${parts[0]}:${parts[1]}";
                return (short, valor);
              });
            }).toList();
            _historicalByFrame = null;
          });
          if (showConfirmation) {
            if (!mounted) return;
            DialogUtils.showSuccessDialog(
                context, 'Métricas obtenidas exitosamente');
          }
        } else {
          logger.e('Error del servidor: ${respuesta.message}');
        }
      } else {
        // Modo Rango de Fechas
        if (startDate == null || endDate == null) return;

        final start = DateFormat('yyyy-MM-dd').format(startDate!);
        final end = DateFormat('yyyy-MM-dd').format(endDate!);
        final url =
            '${Conexion.urlBase}historical/observation/$selectedSensor/range?startDate=$start&endDate=$end';

        final resp = await http.get(Uri.parse(url));

        if (resp.statusCode == 200) {
          final wrapper = jsonDecode(resp.body) as Map<String, dynamic>;

          if (wrapper['status'] == 'SUCCESS' && wrapper['payload'] != null) {
            final payload = wrapper['payload'] as Map<String, dynamic>;
            final Map<String, List<ObservationEntry>> grouped = {};

            payload.forEach((frame, list) {
              grouped[frame] = (list as List).map((obs) {
                final rawDate = obs['date'] as String;
                final parts = (obs['quantity']['time'] as String).split(':');
                final time = '${parts[0]}:${parts[1]}';
                final val = (obs['quantity']['value'] as num).toDouble();
                final type = obs['measurementType'] as String;
                return ObservationEntry(
                  date: rawDate,
                  time: time,
                  value: val,
                  measurementType: type,
                );
              }).toList();
            });

            // Si todos los frames vienen sin datos, mostrar warning y salir
            if (grouped.values.every((lista) => lista.isEmpty)) {
              if (!mounted) return;
              DialogUtils.showWarningDialog(
                context,
                'No hay datos disponibles para el rango de fechas seleccionado',
              );
              return;
            }

            // Caso con datos: actualizar estado y mostrar éxito
            setState(() {
              _historicalByFrame = grouped;
              _metricsHistory = null;
            });

            if (showConfirmation) {
              if (!mounted) return;
              DialogUtils.showSuccessDialog(
                context,
                'Datos históricos obtenidos exitosamente',
              );
            }
          } else {
            if (!mounted) return;
            DialogUtils.showErrorDialog(
              context,
              'No se encontraron datos para el rango seleccionado',
            );
          }
        } else {
          logger.e('Error HTTP: ${resp.statusCode}');
          if (!mounted) return;
          DialogUtils.showErrorDialog(
            context,
            'Error al obtener datos: ${resp.statusCode}',
          );
        }
      }
    } catch (e) {
      logger.e('Error al realizar la solicitud: $e');
      if (!mounted) return;
      DialogUtils.showErrorDialog(context, 'Error: ${e.toString()}');
    } finally {
      if (_isInitialLoad) {
        _isInitialLoad = false;
      }
    }
  }

  Future<void> _exportCsv() async {
    if (startDate == null || endDate == null) return;

    final start = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final end = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final sensorId = selectedSensor ?? _sensors.first.externalId;
    final url =
        '${Conexion.urlBase}observation/export?sensorExternalId=$sensorId&startDate=$start&endDate=$end';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        // Crea un Blob con el CSV y dispara la descarga
        final blob = html.Blob([response.body], 'text/csv');
        final blobUrl = html.Url.createObjectUrlFromBlob(blob);
        html.AnchorElement(href: blobUrl)
          ..setAttribute('download', 'observations_$start.csv')
          ..click();
        html.Url.revokeObjectUrl(blobUrl);
      } else {
        if (!mounted) return;
        DialogUtils.showErrorDialog(
          context,
          'No se pudo exportar el CSV.\nCódigo de respuesta: ${response.statusCode}',
          title: 'Error de Exportación',
        );
      }
    } catch (e) {
      if (!mounted) return;
      DialogUtils.showErrorDialog(
        context,
        'No se pudo exportar el CSV.\nError: ${e.toString()}',
        title: 'Error de Exportación',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const leftReservedSize = 52.0;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AdaptiveTheme.of(context).theme.primaryColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha((0.3 * 255).toInt()),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gráficos Estadísticos',
            style: TextStyle(fontSize: 18),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Tooltip(
                        message:
                            'Seleccione la escala temporal para ver la gráfica deseada', // El mensaje del tooltip
                        child: DropdownButtonFormField<String>(
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: "Escala Temporal",
                            prefixIcon: Icon(Icons.access_time),
                            border: OutlineInputBorder(),
                          ),
                          value: selectedTemporal,
                          items:
                              ['Diaria', 'Rango de Fechas'].map((String scale) {
                            return DropdownMenuItem<String>(
                              value: scale,
                              child: Text(
                                scale,
                                style: const TextStyle(color: Colors.white),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedTemporal = value;
                              if (selectedTemporal == 'Diaria') {
                                _historicalByFrame = null;
                              } else {
                                _metricsHistory = null;
                              }
                            });
                            _reloadData();
                          },
                          selectedItemBuilder: (BuildContext context) {
                            return ['Diaria', 'Rango de Fechas'].map((scale) {
                              return Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  scale,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              );
                            }).toList();
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Dropdown de Sensores
                    Expanded(
                      flex: 3,
                      child: Tooltip(
                        message:
                            'Seleccione el sensor deseado', // El mensaje del tooltip
                        child: DropdownButtonFormField<String>(
                          isExpanded: true,
                          decoration: const InputDecoration(
                            labelText: "Sensores",
                            prefixIcon: Icon(Icons.sensors),
                            border: OutlineInputBorder(),
                          ),
                          value: selectedSensor,
                          items: _sensors.map((sensor) {
                            return DropdownMenuItem<String>(
                              value: sensor.externalId,
                              child: Text(
                                sensor.name,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: const TextStyle(color: Colors.white),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedSensor = value;
                            });
                          },
                          selectedItemBuilder: (BuildContext context) {
                            return _sensors.map((sensor) {
                              return Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  sensor.name,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              );
                            }).toList();
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    if (selectedTemporal == 'Diaria') ...[
                      Expanded(
                        flex: 2,
                        child: Tooltip(
                          message:
                              'Seleccione el intervalo de tiempo en minutos', // El mensaje del tooltip
                          child: DropdownButtonFormField<String>(
                            isExpanded: true,
                            decoration: const InputDecoration(
                              labelText: "Minutos",
                              prefixIcon: Icon(Icons.access_time),
                              border: OutlineInputBorder(),
                            ),
                            value: selectedText,
                            items: valuesMins.keys.map((text) {
                              return DropdownMenuItem<String>(
                                value: text,
                                child: Text(
                                  text,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              // Si no está logueado y no es "30 minutos", mostrar alerta
                              if (!_isLoggedIn && value != "30 minutos") {
                                // Forzamos que la selección siga siendo "30 minutos"
                                setState(() {
                                  selectedText = "30 minutos";
                                  selectedNumericValue =
                                      valuesMins["30 minutos"];
                                });
                                _showLoginRequiredDialog();
                                return;
                              }
                              // Si está logueado o seleccionó "30 minutos":
                              setState(() {
                                selectedText = value;
                                selectedNumericValue = valuesMins[value];
                              });
                            },
                            selectedItemBuilder: (BuildContext context) {
                              return valuesMins.keys.map((text) {
                                return Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    text,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                );
                              }).toList();
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ] else ...[
                      Expanded(
                        flex: 3,
                        child: Tooltip(
                          message:
                              'Seleccione la fecha de inicio para el rango de fechas', // El mensaje del tooltip
                          child: TextFormField(
                            readOnly: true,
                            decoration: const InputDecoration(
                              labelText: "Fecha inicio",
                              prefixIcon: Icon(Icons.calendar_today),
                              border: OutlineInputBorder(),
                            ),
                            onTap: () async {
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: startDate ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (pickedDate != null) {
                                setState(() {
                                  startDate = DateTime(
                                    pickedDate.year,
                                    pickedDate.month,
                                    pickedDate.day,
                                  );
                                });
                              }
                            },
                            controller: TextEditingController(
                              text: startDate != null
                                  ? "${startDate!.year}/${startDate!.month}/${startDate!.day}"
                                  : "",
                            ),
                            style: const TextStyle(
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 3,
                        child: Tooltip(
                          message:
                              'Seleccione la fecha de fin para el rango de fechas', // El mensaje del tooltip
                          child: TextFormField(
                            readOnly: true,
                            decoration: const InputDecoration(
                              labelText: "Fecha fin",
                              prefixIcon: Icon(Icons.calendar_today),
                              border: OutlineInputBorder(),
                            ),
                            onTap: () async {
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: endDate ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (pickedDate != null) {
                                setState(() {
                                  endDate = DateTime(
                                    pickedDate.year,
                                    pickedDate.month,
                                    pickedDate.day,
                                  );
                                });
                              }
                            },
                            controller: TextEditingController(
                              text: endDate != null
                                  ? "${endDate!.year}/${endDate!.month}/${endDate!.day}"
                                  : "",
                            ),
                            style: const TextStyle(
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],

                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                          side: const BorderSide(width: 1),
                        ),
                        backgroundColor: AdaptiveTheme.of(context)
                            .theme
                            .buttonTheme
                            .colorScheme
                            ?.primary,
                        foregroundColor: AdaptiveTheme.of(context)
                            .theme
                            .buttonTheme
                            .colorScheme
                            ?.onPrimary,
                      ),
                      onPressed: () {
                        _reloadData(showConfirmation: true);
                      },
                      child: const Text("Consultar"),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),

          // ============================
          // Encabezado del gráfico
          // ============================
          const Text(
            "Niveles de ruido dB (decibelio)",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),

          if (_historicalByFrame != null) ...[
            // Rango de Fechas: dos charts
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 14),
                Text(
                  'Mediciones históricas',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                SizedBox(
                  height: 300,
                  child: ChartRanges(
                    entries: _historicalByFrame!['NOCTURNO'] ?? [],
                    timeFrame: 'NOCTURNO',
                    sensor: findSensor(selectedSensor ?? ''),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                    height: 300,
                    child: ChartRanges(
                      entries: _historicalByFrame!['DIURNO'] ?? [],
                      sensor: findSensor(selectedSensor ?? ''),
                      timeFrame: 'DIURNO',
                    )),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              alignment: Alignment.centerLeft,
              child: Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(
                      text: 'Descripción: ',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    TextSpan(
                      text:
                          'Las gráficas muestran los registros históricos de ruido que el sensor ${findSensor(selectedSensor ?? '').name} ha captado durante para el intervalo seleccionado (${DateFormat('yyyy/MM/dd').format(startDate!)} - ${DateFormat('yyyy/MM/dd').format(endDate!)}), indicando únicamente los valores máximo, mínimo y promedio en los periodos diurno (de 7:01 a 21:00 ) y nocturno (21:01 a 7:00).',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.justify,
              ),
            ),
          ] else if (_metricsHistory != null) ...[
            SizedBox(
              width: double.infinity,
              child: Column(
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      return width >= 380
                          ? Row(
                              children: [
                                const SizedBox(width: leftReservedSize),
                                const _ChartTitle(),
                                const Spacer(),
                                Center(
                                  child: _TransformationButtons(
                                    controller: _transformationController,
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              children: [
                                const _ChartTitle(),
                                const SizedBox(height: 16),
                                _TransformationButtons(
                                  controller: _transformationController,
                                ),
                              ],
                            );
                    },
                  ),
                  AspectRatio(
                    aspectRatio: 2.2,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 18.0),
                      child: LineChart(
                        transformationConfig: FlTransformationConfig(
                          scaleAxis: FlScaleAxis.horizontal,
                          minScale: 1.0,
                          maxScale: 25.0,
                          transformationController: _transformationController,
                        ),
                        LineChartData(
                          lineBarsData: [
                            LineChartBarData(
                              spots: _metricsHistory?.asMap().entries.map((e) {
                                    final index = e.key;
                                    final item = e.value;
                                    final value = item.$2;
                                    return FlSpot(index.toDouble(), value);
                                  }).toList() ??
                                  [],
                              dotData: FlDotData(
                                show:
                                    true, // Cambiado de 'false' a 'true' para mostrar los puntos
                                getDotPainter: (spot, percent, barData, index) {
                                  return FlDotCirclePainter(
                                    radius: 3, // Tamaño de los puntos
                                    color:
                                        const Color.fromARGB(255, 5, 37, 104),
                                    strokeColor:
                                        Colors.blue, // Color de los puntos
                                    strokeWidth:
                                        2, // Grosor del borde de los puntos
                                  );
                                },
                              ),
                              color: Colors.blue,
                              barWidth: 1,
                              shadow: const Shadow(
                                color: Colors.blue,
                                blurRadius: 2,
                              ),
                              belowBarData: BarAreaData(
                                show: true,
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.blue.withOpacity(0.2),
                                    Colors.blue.withOpacity(0.0)
                                  ],
                                  stops: const [0.5, 1.0],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                          ],
                          lineTouchData: LineTouchData(
                            touchSpotThreshold: 5,
                            getTouchLineStart: (_, _) => -double.infinity,
                            getTouchLineEnd: (_, _) => double.infinity,
                            getTouchedSpotIndicator: (
                              LineChartBarData barData,
                              List<int> spotIndexes,
                            ) {
                              return spotIndexes.map((spotIndex) {
                                return TouchedSpotIndicatorData(
                                  const FlLine(
                                    color: Color(0xFF182B5C),
                                    strokeWidth: 1.5,
                                    dashArray: [8, 2],
                                  ),
                                  FlDotData(
                                    show: true,
                                    getDotPainter:
                                        (spot, percent, barData, index) {
                                      return FlDotCirclePainter(
                                        radius: 6,
                                        color: Colors.blue,
                                        strokeWidth: 0,
                                        strokeColor: Colors.blue,
                                      );
                                    },
                                  ),
                                );
                              }).toList();
                            },
                            touchTooltipData: LineTouchTooltipData(
                              getTooltipItems:
                                  (List<LineBarSpot> touchedBarSpots) {
                                return touchedBarSpots.map((barSpot) {
                                  final price = barSpot.y;
                                  final time =
                                      _metricsHistory![barSpot.x.toInt()].$1;
                                  return LineTooltipItem(
                                    '',
                                    const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: time,
                                        style: const TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                      TextSpan(
                                        text: '\n${NumberFormat.compactCurrency(
                                          locale:
                                              Localizations.localeOf(context)
                                                  .toString(),
                                          symbol: '',
                                        ).format(price)} dB',
                                        style: TextStyle(
                                          color: ChromaticNoise.getValueColor(
                                              price),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList();
                              },
                              getTooltipColor: (LineBarSpot barSpot) =>
                                  const Color(0xFF212332),
                            ),
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            leftTitles: AxisTitles(
                              drawBelowEverything: true,
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: leftReservedSize,
                                maxIncluded: false,
                                minIncluded: false,
                                getTitlesWidget:
                                    (double value, TitleMeta meta) {
                                  return Text(
                                    '${value.toInt()} dB',
                                    style: const TextStyle(
                                      //color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  );
                                },
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 1,
                                reservedSize: 38,
                                getTitlesWidget:
                                    (double value, TitleMeta meta) {
                                  final time =
                                      _metricsHistory![value.toInt()].$1;
                                  return SideTitleWidget(
                                    meta: meta,
                                    child: Transform.rotate(
                                      angle: -45 * 3.14 / 180,
                                      child: Text(
                                        time,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        duration: Duration.zero,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              alignment: Alignment.centerLeft,
              child: const Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Descripción: ',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey),
                    ),
                    TextSpan(
                      text:
                          'La gráfica muestra los niveles de ruido en tiempo real. Los usuarios pueden seleccionar el sensor y ver los datos en intervalos de 5 a 60 minutos. Sin embargo, los intervalos más específicos, solo están disponibles para usuarios con correos institucionales de la Universidad de Loja, mientras que el público general puede acceder a un intervalo de 30 minutos.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                textAlign: TextAlign.justify, // Justificación del texto
              ),
            ),
            const SizedBox(height: 16),
            if (_isLoggedIn)
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: _exportCsv,
                  icon: const Icon(Icons.download),
                  label: const Text("Exportar datos (.csv)"),
                ),
              ),
          ] else ...[
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 10),
                  Text('No hay datos disponibles'),
                ],
              ),
            )
          ],
        ],
      ),
    );
  }

  SensorDTO findSensor(String external) {
    for (SensorDTO sensor in _sensors) {
      if (sensor.externalId == external) {
        return sensor;
      }
    }
    return SensorDTO();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _transformationController.dispose();
    super.dispose();
  }
}

/// Widget interno para el título del chart
class _ChartTitle extends StatelessWidget {
  const _ChartTitle();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 14),
        Text(
          'Mediciones en tiempo real',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        Text(
          'Desde la madrugada de hoy',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        SizedBox(height: 14),
      ],
    );
  }
}

class _TransformationButtons extends StatelessWidget {
  const _TransformationButtons({
    required this.controller,
  });

  final TransformationController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Tooltip(
          message: 'Mover izquierda',
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios, size: 16),
            onPressed: _transformationMoveLeft,
          ),
        ),
        Tooltip(
          message: 'Reset zoom',
          child: IconButton(
            icon: const Icon(Icons.refresh, size: 16),
            onPressed: _transformationReset,
          ),
        ),
        Tooltip(
          message: 'Mover derecha',
          child: IconButton(
            icon: const Icon(Icons.arrow_forward_ios, size: 16),
            onPressed: _transformationMoveRight,
          ),
        ),
        Tooltip(
          message: 'Zoom in',
          child: IconButton(
            icon: const Icon(Icons.add, size: 16),
            onPressed: _transformationZoomIn,
          ),
        ),
        Tooltip(
          message: 'Zoom out',
          child: IconButton(
            icon: const Icon(Icons.minimize, size: 16),
            onPressed: _transformationZoomOut,
          ),
        ),
      ],
    );
  }

  void _transformationReset() {
    controller.value = Matrix4.identity();
  }

  void _transformationZoomIn() {
    controller.value *= Matrix4.diagonal3Values(1.1, 1.1, 1);
  }

  void _transformationMoveLeft() {
    controller.value *= Matrix4.translationValues(20, 0, 0);
  }

  void _transformationMoveRight() {
    controller.value *= Matrix4.translationValues(-20, 0, 0);
  }

  void _transformationZoomOut() {
    controller.value *= Matrix4.diagonal3Values(0.9, 0.9, 1);
  }
}
