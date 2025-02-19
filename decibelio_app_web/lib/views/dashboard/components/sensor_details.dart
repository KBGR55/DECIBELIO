import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:decibelio_app_web/models/metric.dart';
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

  List<Metric> _metrics = [];
  List<SensorDTO> _sensors = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGraphics();
  }

  Future<void> _loadGraphics() async {
    Facade facade = Facade();
    ListMetricDTO metricLastData = await facade.listMetricLastDTO();
    ListSensorDTO sensorData = await facade.listSensorDTO();

    setState(() {
      _metrics = metricLastData.data;
      _sensors = sensorData.data;
      _isLoading = false;
    });
  }

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
                        SensorDTO? sensor =
                            findSensor(metric.sensorExternalId.toString());
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(sensor!.name.toString()),
                            Text("Tipo: ${sensor.sensorType}"),
                            Text("Nivel de Ruido: ${metric.range}"),
                            Chart(
                              range: metric.range.toString(),
                              value:
                                  double.parse(metric.value.toStringAsFixed(2)),
                            ),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                    side: const BorderSide(
                                      color: Color(0XFF4CAE4C),
                                      width: 1,
                                    ),
                                  ),
                                  elevation: 0,
                                  backgroundColor: const Color(0xFF5CB85C),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: defaultPadding,
                                    vertical: 15,
                                  ),
                                ),
                                onPressed: () {
                                  // Encuentra la posición del sensor
                                  /**SensorDTO? sensor = _sensors.firstWhere(
                                        (s) => s.externalId == metric.sensorExternalId,
                                  );*/
                                  for (SensorDTO sensor in _sensors) {
                                    if (sensor.externalId == metric.sensorExternalId) {
                                      mapKey.currentState?.moveToSensor(
                                        LatLng(sensor.latitude, sensor.longitude),
                                        15.0, // Zoom deseado
                                      );
                                    }
                                  }
                                  /**if (sensor != null) {
                                    // Llama al método del mapa
                                    mapKey.currentState?.moveToSensor(
                                      LatLng(sensor.latitude, sensor.longitude),
                                      15.0, // Zoom deseado
                                    );
                                  }*/
                                },
                                child: const Text('Localizar Sensor'),
                              )

                            ),
                            const SizedBox(height: 8)
                          ],
                        );
                      }).toList(),
                    ),
        ],
      ),
    );
  }
}
