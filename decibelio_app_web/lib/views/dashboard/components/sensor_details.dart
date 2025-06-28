import 'dart:async'; // <– Import necesario para Timer
import 'dart:developer';
import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:decibelio_app_web/models/observation.dart';
import 'package:decibelio_app_web/models/sensor_dto.dart';
import 'package:decibelio_app_web/services/facade/facade.dart';
import 'package:decibelio_app_web/services/facade/list/list_metric_dto.dart';
import 'package:decibelio_app_web/services/facade/list/list_sensor_dto.dart';
import 'package:decibelio_app_web/views/dashboard/components/chart_sensor.dart';
import 'package:decibelio_app_web/views/dashboard/components/globals.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../../../constants.dart';

class SensorDetails extends StatefulWidget {
  const SensorDetails({super.key});

  @override
  SensorDetailsState createState() => SensorDetailsState();
}

class SensorDetailsState extends State<SensorDetails> {
  List<Observation> _metrics = [];
  List<SensorDTO> _sensors = [];
  bool _isLoading = true;

  Timer? _pollingTimer; // <– Campo para el Timer periódico

  @override
  void initState() {
    super.initState();
    _loadGraphics(); // Carga inicial de datos
    _startPolling(); // Inicia el polling para recarga cada 5 min
  }

  /// Crea un Timer que cada 5 minutos llama a `_loadGraphics()`
  void _startPolling() {
    _pollingTimer?.cancel(); // Si ya existía un timer, lo cancelamos antes

    _pollingTimer = Timer.periodic(
      const Duration(minutes: 3),
      (timer) async {
        // Si quieres ver en consola cuándo se dispara:
        // print('🔄 Polling: recargando datos desde el servidor...');
        await _loadGraphics();
      },
    );
  }

  /// Cancela el Timer cuando el widget se destruye
  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  /// Método que obtiene las últimas métricas y sensores
  Future<void> _loadGraphics() async {
    setState(() {
      _isLoading = true;
    });

    try {
      Facade facade = Facade();
      ListMetricDTO metricLastData = await facade.listMetricLastDTO();
      ListSensorDTO sensorData = await facade.listSensorDTO();

      setState(() {
        _metrics = metricLastData.data;
        _sensors = sensorData.data;
        _isLoading = false;
      });
    } catch (e) {
      // Maneja errores de petición si es necesario
      log('Error al cargar métricas o sensores: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Busca dentro de _sensors el SensorDTO cuyo externalId coincide
  SensorDTO? findSensor(String external) {
    for (SensorDTO sensor in _sensors) {
      if (sensor.externalId == external) {
        return sensor;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(defaultPadding),
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
            "Últimas mediciones",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: defaultPadding),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _metrics.isEmpty
                  ? const Text("No hay datos disponibles")
                  : Column(
                      children: _metrics.map((metric) {
                        // Para cada métrica, buscamos el sensor asociado
                        SensorDTO? sensor =
                            findSensor(metric.sensorExternalId.toString());
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (sensor != null) ...[
                              Row(
                                children: [
                                  const Icon(Icons.access_time, size: 20),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      'Fecha: ${metric.date ?? 'No disponible'} a las ${metric.quantity.time ?? 'No disponible'}',
                                      style: const TextStyle(fontSize: 16),
                                      overflow: TextOverflow
                                          .ellipsis, // Evita que el texto se desborde
                                    ),
                                  ),
                                ],
                              ),
                              Text(sensor.name.toString()),
                              Text(
                                  "${sensor.sensorType == 'SOUND_LEVEL_METER' ? 'Sonómetro' : sensor.sensorType} - ${sensor.landUseName}"),
                              Chart(
                                range: metric.qualitativeScaleValue.name,
                                value: double.parse(
                                    metric.quantity.value.toStringAsFixed(2)),
                              ),
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  // If the available width is smaller than a certain value, use a Column
                                  if (constraints.maxWidth < 300) {
                                    // Adjust the value as per your design
                                    return Column(
                                      children: [
                                        Text(
                                          "Nivel de Ruido: ${metric.qualitativeScaleValue.name}",
                                          style: const TextStyle(fontSize: 16),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(
                                            height:
                                                8), // Adds some space between the text and button
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                             shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5),
                            side: const BorderSide(width: 1),
                          ),
                                            backgroundColor:
                                                AdaptiveTheme.of(context)
                                                    .theme
                                                    .buttonTheme
                                                    .colorScheme
                                                    ?.primary,
                                            foregroundColor:
                                                AdaptiveTheme.of(context)
                                                    .theme
                                                    .buttonTheme
                                                    .colorScheme
                                                    ?.onPrimary,
                                          ),
                                          onPressed: () {
                                            // Ubicar el sensor en el mapa
                                            mapKey.currentState?.moveToSensor(
                                              LatLng(sensor.latitude,
                                                  sensor.longitude),
                                              15.0, // Zoom deseado
                                            );
                                          },
                                          child: const Tooltip(
                                            message:
                                                'Localizar sensor en el mapa',
                                            child: Text('Ubicar Sensor'),
                                          ),
                                        ),
                                      ],
                                    );
                                  } else {
                                    // If there is enough space, use a Row
                                    return Row(
                                      children: [
                                        Text(
                                          "Nivel de Ruido: ${metric.qualitativeScaleValue.name}",
                                          style: const TextStyle(fontSize: 16),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const Spacer(),
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
                                            // Ubicar el sensor en el mapa
                                            mapKey.currentState?.moveToSensor(
                                              LatLng(sensor.latitude,
                                                  sensor.longitude),
                                              15.0, // Zoom deseado
                                            );
                                          },
                                          child: const Tooltip(
                                            message:
                                                'Localizar sensor en el mapa',
                                            child: Text('Ubicar Sensor'),
                                          ),
                                        ),
                                      ],
                                    );
                                  }
                                },
                              ),
                              const SizedBox(height: 8),
                            ],
                          ],
                        );
                      }).toList(),
                    ),
        ],
      ),
    );
  }
}
