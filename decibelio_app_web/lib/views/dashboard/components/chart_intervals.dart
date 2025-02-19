import 'dart:convert';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:decibelio_app_web/models/sensor_dto.dart';
import 'package:decibelio_app_web/services/conexion.dart';
import 'package:decibelio_app_web/services/facade/facade.dart';
import 'package:decibelio_app_web/services/facade/list/list_sensor_dto.dart';
import 'package:decibelio_app_web/views/dashboard/components/presentation_utils.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class SoundChartView extends StatefulWidget {
  const SoundChartView({super.key});

  @override
  State<SoundChartView> createState() => _SoundChartView();
}

class _SoundChartView extends State<SoundChartView> {
  //eliminar
  final Conexion _conn = Conexion();

  String? selectedSensor;
  DateTime? startDate = DateTime.now();
  DateTime? endDate = DateTime.now();
  List<String> sensorNames = [];
  String? selectedText; // Texto seleccionado
  int? selectedNumericValue; // Valor numérico seleccionado

  List<SensorDTO> _sensors = [];

  final Map<String, int> valuesMins = {
    "60 minutos": 60,
    "50 minutos": 50,
    "40 minutos": 40,
    "30 minutos": 30,
    "20 minutos": 20,
    "10 minutos": 10,
  };

  @override
  void initState() {
    super.initState();
    loadSensorNames(); // Cargar los nombres de los sensores dinámicamente
    _transformationController = TransformationController();
  }

  Future<void> loadSensorNames() async {
    Facade facade = Facade();
    ListSensorDTO sensorData = await facade.listSensorDTO();

    // Simulación de una llamada a un servicio o backend
    await Future.delayed(const Duration(seconds: 1));
    // Simular retardo de red
    setState(() {
      //sensorNames = sensorData.data.map((sensor) => sensor.name).toList(); // Aquí coloca los nombres reales
      _sensors = sensorData.data;
    });
  }

  void applyFilter() {
    // Lógica para aplicar los filtros seleccionados
    if (selectedSensor == null || selectedNumericValue == null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            title: const Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 30),
                SizedBox(width: 10),
                Text('Porfavor llena todos los campos'),
              ],
            ),
          );
        },
      );
    } else {
      _reloadData();
    }
    // Aquí puedes implementar la lógica de carga de datos para la gráfica
  }

  //Variables y metodos graphics
  late TransformationController _transformationController;
  bool _isPanEnabled = true;
  bool _isScaleEnabled = true;
  List<(String, double)>? _metricsHistory;

  String shortTime(String timeString) {
    List<String> parts = timeString.split(":");
    return "${parts[0]}:${parts[1]}";
  }

  void _reloadData() async {
    Map<String, dynamic> data = {
      "sensorExternalId": selectedSensor.toString(),
      "startDate": DateFormat("yyyy-MM-ddTHH:mm:ss")
          .format(startDate!), // Formato: "YYYY-MM-DDTHH:mm:ss"
      "endDate": DateFormat("yyyy-MM-ddTHH:mm:ss")
          .format(endDate!), // Formato: "YYYY-MM-DDTHH:mm:ss"
      "intervalMinutes": selectedNumericValue,
    };
    try {
      final respuesta = await _conn.solicitudPost('metrics/sensor', data, "NO");
      final metrics = jsonDecode(respuesta.payload) as Map<String, dynamic>;
      setState(() {
        _metricsHistory = (metrics['payload'] as List)
            .expand((item) => (item['metrics'] as List).map((metric) =>
                (shortTime(metric['time']), metric['value'] as double)))
            .toList();
      });
      showDialog(
          // ignore: use_build_context_synchronously
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              title: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.blue, size: 30),
                  SizedBox(width: 10),
                  Text('Métricas obtenidas correctamente'),
                ],
              ),
            );
          });
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al realizar la solicitud: $e")),
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
          const Text('Gráficos Estadísticos', style: TextStyle(fontSize: 18)),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Dropdown para seleccionar el sensor
                    Expanded(
                        child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: "Sensores",
                        prefixIcon: Icon(Icons.sensors),
                        border: OutlineInputBorder(),
                      ),
                      value:
                          selectedSensor, // Aquí seleccionamos el externalID actual.
                      items: _sensors.map((sensor) {
                        return DropdownMenuItem<String>(
                          value: sensor
                              .externalId, // Asigna el externalID como valor.
                          child: Text(sensor.name,
                              style: const TextStyle(
                                  color: Colors
                                      .white)), // Muestra el nombre del sensor en la lista.
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedSensor =
                              value; // Actualiza el externalID seleccionado.
                        });
                      },
                    )),
                    const SizedBox(width: 16),
                    // Campo para seleccionar la fecha de inicio
                    Expanded(
                      child: TextFormField(
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: "Fecha y Hora de inicio",
                          prefixIcon: Icon(Icons.calendar_today),
                          border: OutlineInputBorder(),
                        ),
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );

                          if (pickedDate != null) {
                            TimeOfDay? pickedTime = await showTimePicker(
                              initialTime: TimeOfDay.now(),
                              // ignore: use_build_context_synchronously
                              context: context,
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
                              ? "${startDate!.month}/${startDate!.day}/${startDate!.year} ${startDate!.hour}:${startDate!.minute.toString().padLeft(2, '0')}"
                              : "",
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Campo para seleccionar la fecha de fin
                    Expanded(
                      child: TextFormField(
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: "Fecha y Hora fin",
                          prefixIcon: Icon(Icons.calendar_today),
                          border: OutlineInputBorder(),
                        ),
                        onTap: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );

                          if (pickedDate != null) {
                            TimeOfDay? pickedTime = await showTimePicker(
                              // ignore: use_build_context_synchronously
                              context: context,
                              initialTime: TimeOfDay.now(),
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
                              ? "${endDate!.month}/${endDate!.day}/${endDate!.year} ${endDate!.hour}:${endDate!.minute.toString().padLeft(2, '0')}"
                              : "",
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButtonFormField<String>(
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
                              style: const TextStyle(color: Colors.white),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedText = value;
                            selectedNumericValue = valuesMins[
                                value]; // Obtener el valor numérico asociado
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Botón para aplicar el filtro
                    ElevatedButton(
                      onPressed: applyFilter,
                      child: const Text("Consultar"),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          const Text(
            "Niveles de ruido dB (decibelio)",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Frecuencia en horas / A partir del 03-Dic-2024 01:15:18.",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            //height: 300,
            child: Column(
              //spacing: 16,
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
                    //spacing: 16,
                    children: [
                      const Text('Pan'),
                      Switch(
                        value: _isPanEnabled,
                        onChanged: (value) {
                          setState(() {
                            _isPanEnabled = value;
                          });
                        },
                      ),
                      const Text('Scale'),
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
                  aspectRatio: 1.4,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 0.0,
                      right: 18.0,
                    ),
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
                            dotData: const FlDotData(show: false),
                            color: Colors.amber,
                            barWidth: 1,
                            shadow: const Shadow(
                              color: Colors.amber,
                              blurRadius: 2,
                            ),
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: const LinearGradient(
                                colors: [Colors.amberAccent, Colors.amber],
                                stops: [0.5, 1.0],
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
                          getTouchedSpotIndicator: (LineChartBarData barData,
                              List<int> spotIndexes) {
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
                                      text: '\n${AppUtils.getFormattedCurrency(
                                        context,
                                        price,
                                        noDecimals: true,
                                      )}',
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
                          leftTitles: const AxisTitles(
                            drawBelowEverything: true,
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: leftReservedSize,
                              maxIncluded: false,
                              minIncluded: false,
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 38,
                              maxIncluded: false,
                              getTitlesWidget: (double value, TitleMeta meta) {
                                final time = _metricsHistory![value.toInt()].$1;
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
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: () {
                // Lógica para exportar datos
              },
              icon: const Icon(Icons.download),
              label: const Text("Exportar datos (.xls)"),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }
}

class _ChartTitle extends StatelessWidget {
  const _ChartTitle();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 14),
        Text(
          'History',
          style: TextStyle(
            color: Colors.amber,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        Text(
          '2023/12/19 - 2024/12/17',
          style: TextStyle(
            color: Colors.green,
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
    return Column(
      children: [
        Tooltip(
          message: 'Zoom in',
          child: IconButton(
            icon: const Icon(
              Icons.add,
              size: 16,
            ),
            onPressed: _transformationZoomIn,
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Tooltip(
              message: 'Move left',
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios,
                  size: 16,
                ),
                onPressed: _transformationMoveLeft,
              ),
            ),
            Tooltip(
              message: 'Reset zoom',
              child: IconButton(
                icon: const Icon(
                  Icons.refresh,
                  size: 16,
                ),
                onPressed: _transformationReset,
              ),
            ),
            Tooltip(
              message: 'Move right',
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                ),
                onPressed: _transformationMoveRight,
              ),
            ),
          ],
        ),
        Tooltip(
          message: 'Zoom out',
          child: IconButton(
            icon: const Icon(
              Icons.minimize,
              size: 16,
            ),
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
    controller.value *= Matrix4.diagonal3Values(
      1.1,
      1.1,
      1,
    );
  }

  void _transformationMoveLeft() {
    controller.value *= Matrix4.translationValues(
      20,
      0,
      0,
    );
  }

  void _transformationMoveRight() {
    controller.value *= Matrix4.translationValues(
      -20,
      0,
      0,
    );
  }

  void _transformationZoomOut() {
    controller.value *= Matrix4.diagonal3Values(
      0.9,
      0.9,
      1,
    );
  }
}
