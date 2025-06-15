import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:decibelio_app_web/services/auth_service.dart';
import 'package:decibelio_app_web/models/sensor_dto.dart';
import 'package:decibelio_app_web/services/conexion.dart';
import 'package:decibelio_app_web/services/facade/facade.dart';
import 'package:decibelio_app_web/services/facade/list/list_sensor_dto.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

class ObservationEntry {
  final String date;
  final String time;
  final double value;
  final String measurementType;
  ObservationEntry({
    required this.date,
    required this.time,
    required this.value,
    required this.measurementType,
  });
}

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
  bool _isPanEnabled = true;
  bool _isScaleEnabled = true;

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

  /// Muestra un AlertDialog de “debes iniciar sesión” si intenta cambiar minutos sin estar logueado
  void _showLoginRequiredDialog() {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 30),
              SizedBox(width: 8),
              Text('Inicio de sesión requerido'),
            ],
          ),
          content: const Text(
            'Debes iniciar sesión con tu correo institucional para seleccionar un intervalo diferente de 30 minutos.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Entendido'),
            ),
          ],
        );
      },
    );
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
            _showSuccessDialog('Métricas obtenidas exitosamente');
          }
        } else {
          logger.e('Error del servidor: ${respuesta.message}');
          _showErrorDialog('Error al obtener datos: ${respuesta.message}');
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

            setState(() {
              _historicalByFrame = grouped;
              _metricsHistory = null;
            });

            if (showConfirmation) {
              _showSuccessDialog('Datos históricos obtenidos exitosamente');
            }
          } else {
            _showErrorDialog(
                'No se encontraron datos para el rango seleccionado');
          }
        } else {
          logger.e('Error HTTP: ${resp.statusCode}');
          _showErrorDialog('Error al obtener datos: ${resp.statusCode}');
        }
      }
    } catch (e) {
      logger.e('Error al realizar la solicitud: $e');
      _showErrorDialog('Error: ${e.toString()}');
    } finally {
      if (_isInitialLoad) {
        _isInitialLoad = false;
      }
    }
  }

  void _showSuccessDialog(String message) {
    if (!mounted) return;
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.blue, size: 30),
            SizedBox(width: 10),
            Text('Éxito'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    if (!mounted) return;
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 28),
            SizedBox(width: 8),
            Text('Error'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportCsv() async {
    if (startDate == null || endDate == null) return;

    final start = DateFormat('yyyy-MM-dd').format(startDate!);
    final end = DateFormat('yyyy-MM-dd').format(endDate!);
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
          ..setAttribute('download', 'observations_${start}_to_${end}.csv')
          ..click();
        html.Url.revokeObjectUrl(blobUrl);
      } else {
        if (!mounted) return;
        await showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 28),
                SizedBox(width: 8),
                Text('Error de Exportación'),
              ],
            ),
            content: Text(
              'No se pudo exportar el CSV.\nCódigo de respuesta: ${response.statusCode}',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cerrar'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 28),
              SizedBox(width: 8),
              Text('Excepción'),
            ],
          ),
          content: Text(
            'Ocurrió un error al exportar:\n$e',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        ),
      );
    }
  }

  /// Builds a LineChart showing separate lines for each measurement type
Widget _buildLineChart(List<ObservationEntry> entries, String timeFrame) {
  if (entries.isEmpty) return const SizedBox.shrink();

  // Agrupar por fecha
  final dates = entries.map((e) => e.date).toSet().toList()..sort();
  final datePositions = {for (var i = 0; i < dates.length; i++) dates[i]: i.toDouble()};

  // Variables de estado para controlar qué puntos se muestran
  bool showMax = true;
  bool showAvg = true;
  bool showMin = true;

  return StatefulBuilder(
    builder: (context, setState) {
      // Extrae una lista por tipo
      final maxEntries = showMax
          ? entries.where((e) => e.measurementType == 'MAX').toList()
          : [];
      final avgEntries = showAvg
          ? entries.where((e) => e.measurementType == 'AVERAGE').toList()
          : [];
      final minEntries = showMin
          ? entries.where((e) => e.measurementType == 'MIN').toList()
          : [];

      // Función colorear puntos
      Color _color(String t) => t == 'MAX'
          ? Colors.red
          : t == 'MIN'
              ? Colors.blue
              : Colors.green;

      // Cada serie: puntos por fecha
      List<LineChartBarData> series = [
        if (maxEntries.isNotEmpty)
          LineChartBarData(
            spots: maxEntries.map((e) => FlSpot(datePositions[e.date]!, e.value)).toList(),
            isCurved: false,
            barWidth: 2,
            dotData: FlDotData(show: true),
            color: _color('MAX'),
          ),
        if (avgEntries.isNotEmpty)
          LineChartBarData(
            spots: avgEntries.map((e) => FlSpot(datePositions[e.date]!, e.value)).toList(),
            isCurved: false,
            barWidth: 2,
            dotData: FlDotData(show: true),
            color: _color('AVERAGE'),
          ),
        if (minEntries.isNotEmpty)
          LineChartBarData(
            spots: minEntries.map((e) => FlSpot(datePositions[e.date]!, e.value)).toList(),
            isCurved: false,
            barWidth: 2,
            dotData: FlDotData(show: true),
            color: _color('MIN'),
          ),
      ];

      return Column(
        children: [
          Text(
            timeFrame == 'NOCTURNO' ? 'Período NOCTURNO' : 'Período DIURNO',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: timeFrame == 'NOCTURNO' ? Colors.blue : Colors.orange,
            ),
          ),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                lineBarsData: series,
                gridData: FlGridData(show: true),
                borderData: FlBorderData(
                  show: true,
                  border: const Border(
                    left: BorderSide(),
                    bottom: BorderSide(),
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) => Text(
                          '${value.toInt().toString()} dB',
                          style: const TextStyle(fontSize: 10)),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 38,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= dates.length) return const Text('');
                        final date = dates[value.toInt()];
                        return SideTitleWidget(
                          meta: meta,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              DateFormat('dd/MM').format(DateTime.parse(date)),
                              style: const TextStyle(fontSize: 10),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (LineBarSpot barSpot) => Colors.black,
                    getTooltipItems: (spots) => spots.map((spot) {
                      if (spot.x.toInt() >= dates.length) return null;
                      final date = dates[spot.x.toInt()];
                      final entry = [maxEntries, avgEntries, minEntries][spot.barIndex]
                          .firstWhere((e) => e.date == date);
                      return LineTooltipItem(
                        '',
                        const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        children: [
                          TextSpan(
                            text: '${entry.measurementType}\n',
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          TextSpan(
                            text: '${entry.time}\n${entry.value} dB',
                            style: const TextStyle(
                              color: Colors.amber,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          TextSpan(
                            text: '\n${DateFormat('dd/MM/yyyy').format(DateTime.parse(date))}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      );
                    }).where((item) => item != null).toList(),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: ['MAX', 'AVERAGE', 'MIN'].map((t) {
              final isActive = (t == 'MAX' && showMax) ||
                  (t == 'AVERAGE' && showAvg) ||
                  (t == 'MIN' && showMin);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (t == 'MAX') {
                      showMax = !showMax;
                    } else if (t == 'AVERAGE') {
                      showAvg = !showAvg;
                    } else if (t == 'MIN') {
                      showMin = !showMin;
                    }
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        color: isActive ? _color(t) : Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        t,
                        style: TextStyle(
                          color: isActive ? Colors.blue : Colors.grey,
                          decoration: isActive
                              ? TextDecoration.none
                              : TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      );
    },
  );
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
                    //Escala temporal
                    Expanded(
                      flex: 3,
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: "Escala Temporal",
                          prefixIcon: Icon(Icons.access_time),
                          border: OutlineInputBorder(),
                        ),
                        value:
                            selectedTemporal, // Asegúrate de tener 'selectedText' como variable para la selección.
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
                    const SizedBox(width: 12),
                    // Dropdown de Sensores
                    Expanded(
                      flex: 3,
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
                    const SizedBox(width: 12),
                    if (selectedTemporal == 'Diaria') ...[
                      // Dropdown “Minutos”
                      Expanded(
                        flex: 2,
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
                                selectedNumericValue = valuesMins["30 minutos"];
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

                      const SizedBox(width: 12),
                    ] else ...[
                      // Fecha y Hora inicio
                      Expanded(
                        flex: 3,
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
                              TimeOfDay? pickedTime = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.fromDateTime(startDate!),
                              );
                              if (pickedTime != null) {
                                setState(() {
                                  startDate = DateTime(
                                    pickedDate.year,
                                    pickedDate.month,
                                    pickedDate.day,
                                    pickedTime.hour,
                                    pickedTime.minute,
                                  );
                                });
                              }
                            }
                          },
                          controller: TextEditingController(
                            text: startDate != null
                                ? "${startDate!.month}/${startDate!.day}/${startDate!.year} "
                                    "${startDate!.hour.toString().padLeft(2, '0')}:"
                                    "${startDate!.minute.toString().padLeft(2, '0')}"
                                : "",
                          ),
                          style: const TextStyle(
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Fecha y Hora fin
                      Expanded(
                        flex: 3,
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
                              TimeOfDay? pickedTime = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.fromDateTime(endDate!),
                              );
                              if (pickedTime != null) {
                                setState(() {
                                  endDate = DateTime(
                                    pickedDate.year,
                                    pickedDate.month,
                                    pickedDate.day,
                                    pickedTime.hour,
                                    pickedTime.minute,
                                  );
                                });
                              }
                            }
                          },
                          controller: TextEditingController(
                            text: endDate != null
                                ? "${endDate!.month}/${endDate!.day}/${endDate!.year} "
                                    "${endDate!.hour.toString().padLeft(2, '0')}:"
                                    "${endDate!.minute.toString().padLeft(2, '0')}"
                                : "",
                          ),
                          style: const TextStyle(
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],

                    ElevatedButton(
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
  Column(
    children: [
      SizedBox(
        height: 300,
        child: _buildLineChart(_historicalByFrame!['NOCTURNO'] ?? [], 'NOCTURNO'),
      ),
      const SizedBox(height: 20),
      SizedBox(
        height: 300,
        child: _buildLineChart(_historicalByFrame!['DIURNO'] ?? [], 'DIURNO'),
      ),
    ],
  )
]else if (_metricsHistory != null) ...[
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text('Fijar'),
                        Switch(
                          value: _isPanEnabled,
                          onChanged: (value) {
                            setState(() {
                              _isPanEnabled = value;
                            });
                          },
                        ),
                        const Text('Zoom'),
                        Switch(
                          value: _isScaleEnabled,
                          onChanged: (value) {
                            setState(() {
                              _isScaleEnabled = value;
                            });
                          },
                        ),
                      ],
                    ),
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
                          panEnabled: _isPanEnabled,
                          scaleEnabled: _isScaleEnabled,
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
                            getTouchLineStart: (_, __) => -double.infinity,
                            getTouchLineEnd: (_, __) => double.infinity,
                            getTouchedSpotIndicator: (
                              LineChartBarData barData,
                              List<int> spotIndexes,
                            ) {
                              return spotIndexes.map((spotIndex) {
                                return TouchedSpotIndicatorData(
                                  const FlLine(
                                    color: Colors.red,
                                    strokeWidth: 1.5,
                                    dashArray: [8, 2],
                                  ),
                                  FlDotData(
                                    show: true,
                                    getDotPainter:
                                        (spot, percent, barData, index) {
                                      return FlDotCirclePainter(
                                        radius: 6,
                                        color: Colors.amber,
                                        strokeWidth: 0,
                                        strokeColor: Colors.amber,
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
                                        style: const TextStyle(
                                          color: Colors.amber,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList();
                              },
                              getTooltipColor: (LineBarSpot barSpot) =>
                                  Colors.black,
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
                                reservedSize: 38,
                                maxIncluded: false,
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
                                          color: Colors.green,
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
            const Text(
              "Descripción: Cualquier cosa",
              style: TextStyle(fontSize: 12, color: Colors.grey),
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

/// Botones de transformación (pan/zoom) para el chart
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
