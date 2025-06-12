import 'dart:async';
import 'package:decibelio_app_web/services/facade/list/list_sensor_dto.dart';
import 'package:flutter/material.dart';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:decibelio_app_web/services/facade/facade.dart'; // Importa tu servicio Facade
import 'package:decibelio_app_web/models/noise_measurement.dart'; // Importa la clase NoiseMeasurement
import 'package:decibelio_app_web/models/sensor_dto.dart'; // Asegúrate de tener la clase SensorDTO

class NoiseMeasurementDetails extends StatefulWidget {
  const NoiseMeasurementDetails({super.key});

  @override
  NoiseMeasurementDetailsState createState() => NoiseMeasurementDetailsState();
}

class NoiseMeasurementDetailsState extends State<NoiseMeasurementDetails> {
  List<NoiseMeasurement> _noiseMeasurements =
      []; // Cambiado de Observation a NoiseMeasurement
  List<SensorDTO> _sensors = [];
  bool _isLoading = true;

  Timer? _pollingTimer; // Timer para actualizar las mediciones cada minuto

  @override
  void initState() {
    super.initState();
    _loadSensorData(); // Inicia la carga de datos de sensores y mediciones
    _startPolling(); // Inicia el temporizador para actualizar cada minuto
  }

  // Método para iniciar el temporizador que actualiza los datos cada minuto
  void _startPolling() {
    _pollingTimer?.cancel(); // Cancelar cualquier temporizador anterior

    _pollingTimer = Timer.periodic(
      const Duration(minutes: 1), // Actualiza cada minuto
      (timer) async {
        await _loadSensorData(); // Cargar los datos actualizados
      },
    );
  }

  @override
  void dispose() {
    _pollingTimer
        ?.cancel(); // Asegurarse de cancelar el temporizador cuando el widget se destruye
    super.dispose();
  }

  // Método para cargar los datos de los sensores y las mediciones de ruido
  Future<void> _loadSensorData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      Facade facade = Facade();
      ListSensorDTO sensorData =
          await facade.listSensorDTO(); // Obtén los sensores activos
      List<NoiseMeasurement> noiseMeasurements = [];

      // Para cada sensor, obtenemos sus mediciones
      for (var sensor in sensorData.data) {
        var noiseMeasurementData =
            await facade.listNoiseMeasurementsDTO(sensor.externalId);

        noiseMeasurements.addAll(noiseMeasurementData.data);
      }

      setState(() {
        _sensors = sensorData.data;
        _noiseMeasurements = noiseMeasurements;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error al cargar los datos del sensor o las mediciones: $e');
    }
  }

  // Función para obtener el color según el nivel de ruido
  Color _getColorForLevel(double nivel) {
    if (nivel >= 120) {
      return const Color(0xFFFF0000); // Excesivamente ruidoso (110-120)
    } else if (nivel >= 110) {
      return const Color(0xFFFC2C00); // Excesivamente ruidoso (100-110)
    } else if (nivel >= 100) {
      return const Color(0xFFFA5700); // Excesivamente ruidoso (90-100)
    } else if (nivel >= 90) {
      return const Color(0xFFF78100); // Muy ruidoso (80-90)
    } else if (nivel >= 80) {
      return const Color(0xFFF5AB00); // Muy ruidoso (70-80)
    } else if (nivel >= 70) {
      return const Color(0xFFF3D300); // Ruidoso (60-70)
    } else if (nivel >= 60) {
      return const Color(0xFFE5F000); // Poco ruidoso (50-60)
    } else if (nivel >= 50) {
      return const Color(0xFFBAEE00); // Poco ruidoso (40-50)
    } else if (nivel >= 40) {
      return const Color(0xFF8FEC00); // Silencioso (30-40)
    } else if (nivel >= 30) {
      return const Color(0xFF64E900); // Silencioso (20-30)
    } else if (nivel >= 20) {
      return const Color(0xFF13E500); // Muy silencioso (0-20)
    } else {
      return const Color(0xFF13E500); // Muy silencioso (0-20)
    }
  }

  // Función para obtener el mensaje del Tooltip según el nivel de ruido
  String _getTooltipMessage(double nivel) {
    if (nivel >= 120) {
      return "Excesivamente ruidoso";
    } else if (nivel >= 110) {
      return "Excesivamente ruidoso";
    } else if (nivel >= 100) {
      return "Excesivamente ruidoso";
    } else if (nivel >= 90) {
      return "Muy ruidoso";
    } else if (nivel >= 80) {
      return "Muy ruidoso";
    } else if (nivel >= 70) {
      return "Ruidoso";
    } else if (nivel >= 60) {
      return "Poco ruidoso";
    } else if (nivel >= 50) {
      return "Poco ruidoso";
    } else if (nivel >= 40) {
      return "Silencioso";
    } else if (nivel >= 30) {
      return "Silencioso";
    } else if (nivel >= 20) {
      return "Muy silencioso";
    } else {
      return "Muy silencioso";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AdaptiveTheme.of(context).theme.primaryColor,
        borderRadius: const BorderRadius.all(Radius.circular(10)),
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
            "Resumen de Mediciones", // Título de la sección
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _noiseMeasurements.isEmpty
                  ? const Text("No hay datos disponibles")
                  : Column(
                      children: _sensors.map((sensor) {
                        // Filtra las mediciones por cada sensor
                        var sensorMeasurements = _noiseMeasurements
                            .where((measurement) =>
                                measurement.sensorExternalId ==
                                sensor.externalId)
                            .toList();

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sensor.name, // Nombre del sensor
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                columnSpacing: 16.0,
                                horizontalMargin: 8.0,
                                columns: const [
                                  DataColumn(
                                    label: Text(
                                      "",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      "Máximo (dB)",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      "Mínimo (dB)",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      "Promedio (dB)",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                                rows: sensorMeasurements.map((measurement) {
                                  return DataRow(cells: [
                                    DataCell(
                                      Row(
                                        children: [
                                          Icon(
                                            measurement.timeFrame == "DIURNO"
                                                ? Icons.wb_sunny
                                                : Icons.nights_stay,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 4),
                                          Tooltip(
                                              message:
                                                  'Desde ${measurement.startTime} a ${measurement.endTime}',
                                              child: Text(
                                                measurement.timeFrame,
                                                style: const TextStyle(
                                                    fontSize: 16),
                                              ))
                                        ],
                                      ),
                                    ),
                                    DataCell(
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            color: _getColorForLevel(
                                                measurement.maxValue),
                                            child: Tooltip(
                                              message: _getTooltipMessage(
                                                  measurement.maxValue),
                                              child: Text(measurement.maxValue
                                                  .toString()),
                                            ),
                                          ),
                                          const SizedBox(
                                              width:
                                                  8), // Espacio entre los textos
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            child: Text(
                                              measurement.maxTime.toString(),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    DataCell(
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            color: _getColorForLevel(
                                                measurement.minValue),
                                            child: Tooltip(
                                              message: _getTooltipMessage(
                                                  measurement.minValue),
                                              child: Text(measurement.minValue
                                                  .toString()),
                                            ),
                                          ),
                                          const SizedBox(
                                              width:
                                                  8), // Espacio entre los textos
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            child: Text(
                                              measurement.minTime.toString(),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    DataCell(
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        color: _getColorForLevel(
                                            measurement.avgValue),
                                        child: Tooltip(
                                          message: _getTooltipMessage(
                                              measurement.avgValue),
                                          child: Text(measurement.avgValue
                                              .toStringAsFixed(3)),
                                        ),
                                      ),
                                    ),
                                  ]);
                                }).toList(),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
        ],
      ),
    );
  }
}
