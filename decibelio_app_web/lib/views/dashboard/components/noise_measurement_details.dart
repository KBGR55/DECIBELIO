import 'dart:async';
import 'package:decibelio_app_web/services/facade/list/list_sensor_dto.dart';
import 'package:decibelio_app_web/utils/chromatic_noise.dart';
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
  final ScrollController horizontalController = ScrollController();

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
      const Duration(minutes: 3), // Actualiza cada minuto
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
      debugPrint('Error al cargar los datos del sensor o las mediciones: $e');
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
            "Resumen de mediciones del día de hoy",
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
                            Scrollbar(
                              controller: horizontalController,
                              thumbVisibility: true,
                              trackVisibility: true,
                              thickness: 8,
                              radius: const Radius.circular(4),
                              child: SingleChildScrollView(
                                controller: horizontalController,
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  columnSpacing: 16.0,
                                  horizontalMargin: 8.0,
                                  columns: const [
                                    DataColumn(label: Text("")),
                                    DataColumn(
                                        label: Text("Máximo (dB)",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold))),
                                    DataColumn(
                                        label: Text("Mínimo (dB)",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold))),
                                    DataColumn(
                                        label: Text("Promedio",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold))),
                                  ],
                                  rows:
                                      sensorMeasurements.expand((measurement) {
                                    return [
                                      // Fila 1: Icono + valores
                                      DataRow(cells: [
                                        DataCell(Row(
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
                                                    fontSize: 16,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                          ],
                                        )),
                                        DataCell(Container(
                                          padding: const EdgeInsets.all(8),
                                          color: ChromaticNoise.getValueColor(measurement.maxValue),
                                          child: Tooltip(
                                            message: ChromaticNoise.getTooltipMessage(
                                                measurement.maxValue),
                                            child: Text(measurement.maxValue
                                                .toStringAsFixed(3)),
                                          ),
                                        )),
                                        DataCell(Container(
                                          padding: const EdgeInsets.all(8),
                                          color: ChromaticNoise.getValueColor(measurement.minValue),
                                          child: Tooltip(
                                            message: ChromaticNoise.getTooltipMessage(
                                                measurement.minValue),
                                            child: Text(measurement.minValue
                                                .toStringAsFixed(3)),
                                          ),
                                        )),
                                        DataCell(Container(
                                          padding: const EdgeInsets.all(8),
                                          color: ChromaticNoise.getValueColor(measurement.avgValue),
                                          child: Tooltip(
                                            message: ChromaticNoise.getTooltipMessage(measurement.avgValue),
                                            child: Text(measurement.avgValue
                                                .toStringAsFixed(3)),
                                          ),
                                        )),
                                      ]),
                                      // Fila 2: Horas
                                      DataRow(cells: [
                                        const DataCell(Text("")),
                                        DataCell(Text(
                                            measurement.maxTime.toString())),
                                        DataCell(Text(
                                            measurement.minTime.toString())),
                                        const DataCell(Text("")),
                                      ]),
                                    ];
                                  }).toList(),
                                ),
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
