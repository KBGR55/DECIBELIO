import 'dart:async';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:decibelio_app_web/services/facade/list/list_sensor_dto.dart';
import 'package:decibelio_app_web/utils/chromatic_noise.dart';
import 'package:decibelio_app_web/views/dashboard/components/globals.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:latlong2/latlong.dart';
import 'package:decibelio_app_web/services/facade/facade.dart';
import 'package:decibelio_app_web/services/facade/list/list_metric_dto.dart';

class AnimatedMapControllerPage extends StatefulWidget {
  static const String route = '/map_controller_animated';

  AnimatedMapControllerPage({Key? key}) : super(key: mapKey);

  @override
  AnimatedMapControllerPageState createState() =>
      AnimatedMapControllerPageState();
}

class AnimatedMapControllerPageState extends State<AnimatedMapControllerPage>
    with TickerProviderStateMixin {
  GlobalKey<ScaffoldState> mapScreenKey = GlobalKey<ScaffoldState>();
  static const _unl = LatLng(-4.032126227155394, -79.20267644603182);
  static const _loja = LatLng(-4.0050051, -79.2046022);
  final Facade _facade = Facade();
  ListSensorDTO? sensors;
  ListMetricDTO? metricLast;
  final List<Marker> _markers = [];
  final mapController = MapController();
  double _currentZoom = 12.0;

  void _zoomIn() {
    setState(() {
      if (_currentZoom < 18.0) {
        _currentZoom++;
        mapController.move(_loja, _currentZoom);
      }
    });
  }

  void _zoomOut() {
    setState(() {
      if (_currentZoom > 5.0) {
        _currentZoom--;
        mapController.move(_loja, _currentZoom);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchSensors();
  }

  void moveToSensor(LatLng location, double zoom) {
    _animatedMapMove(location, zoom);
  }

  void _fetchSensors() async {
    try {
      ListSensorDTO sensorData = await _facade.listSensorDTO();
      if (sensorData.status == 'SUCCESS') {
        ListMetricDTO metricLastData = await _facade.listMetricLastDTO();
        setState(() {
          sensors = sensorData;
          metricLast = metricLastData;
          _populateMarkers();
        });
      } else {
        debugPrint("Failed to fetch sensors: ${sensorData.message}");
      }
    } catch (e) {
      debugPrint("Error fetching sensors: $e");
    }
  }

  void _populateMarkers() {
    _markers.clear();
    if (sensors != null && sensors!.data.isNotEmpty) {
      for (var sensor in sensors!.data) {
        Marker marker = Marker(
            width: 45,
            height: 45,
            point: LatLng(sensor.latitude, sensor.longitude),
            child: GestureDetector(
              onTap: () {
                String? value;
                String? date;
                String? time;
                String? escala;

                // Buscar la métrica correspondiente al sensor
                if (metricLast != null) {
                  for (var metric in metricLast!.data) {
                    if (metric.sensorExternalId == sensor.externalId) {
                      value = metric.quantity.value.toString();
                      date = metric.date; // Obtener la fecha
                      time = metric.quantity.time; // Obtener la hora
                      escala = metric.qualitativeScaleValue.name;
                      break;
                    }
                  }
                }
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    // —————— 1) Inicia el StatefulBuilder ——————
                    return StatefulBuilder(
                      builder: (context, setState) {
                        return AlertDialog(
                          title: Text(sensor.name),
                          content: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.access_time, size: 20),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Fecha: ${date ?? 'No disponible'} a las ${time ?? 'No disponible'}',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                    'Tipo de sensor: ${sensor.sensorType == "SOUND_LEVEL_METER" ? "Sonómetro" : sensor.sensorType}'),
                                const SizedBox(height: 8),
                                Text('Uso de suelo: ${sensor.landUseName}'),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Text('Valor: '),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: ChromaticNoise.getValueColor(
                                            double.tryParse(value ?? '')),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      // ← Interpolación corregida:
                                      child: Text(
                                        '${value ?? 'No disponible'} dB',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Text(' - ${escala ?? 'No disponible'}'),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                    'Referencia: ${sensor.referenceLocation ?? 'No disponible'}'),
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(
                              child: const Text('Cerrar'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                ).then((_) {});
              },
              child: Tooltip(
                message:
                    'Para más información, dar clic', // El texto que aparecerá en el tooltip
                child: Stack(
                  alignment: Alignment
                      .center, // Centra el ícono del sensor dentro del marcador
                  children: [
                    SvgPicture.asset(
                      'assets/icons/map-marker-svgrepo-com.svg',
                      width: 45,
                      height: 45,
                      color: ChromaticNoise.getValueColor(
                          metricLast!.data.last.quantity.value),
                    ),
                    const Icon(
                      Icons.location_on, // Cambia esto por el ícono que desees
                      size: 20, // Ajusta el tamaño del ícono del sensor
                      color: Colors.red,
                      // Color del ícono
                    ),
                  ],
                ),
              ),
            ));
        _markers.add(marker);
      }
    } else {
      debugPrint("No sensors available or sensors data is null.");
    }
  }

  void _animatedMapMove(LatLng destLocation, double destZoom) {
    final camera = mapController.camera;
    final latTween = Tween<double>(
        begin: camera.center.latitude, end: destLocation.latitude);
    final lngTween = Tween<double>(
        begin: camera.center.longitude, end: destLocation.longitude);
    final zoomTween = Tween<double>(begin: camera.zoom, end: destZoom);

    final controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    final Animation<double> animation =
        CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);

    controller.addListener(() {
      mapController.move(
        LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
        zoomTween.evaluate(animation),
      );
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });

    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: <Widget>[
                  MaterialButton(
                    onPressed: () => _animatedMapMove(_loja, 15),
                    child: Tooltip(
                      message: 'Centrar el mapa en Loja', // Mensaje del Tooltip
                      child: Text(
                        'Loja',
                        style: TextStyle(
                          color: AdaptiveTheme.of(context)
                              .theme
                              .primaryTextTheme
                              .titleSmall!
                              .color,
                        ),
                      ),
                    ),
                  ),
                  MaterialButton(
                    onPressed: () => _animatedMapMove(_unl, 15),
                    child: Tooltip(
                      message:
                          'Centrar el mapa en la Universidad Nacional de Loja', // Mensaje del Tooltip
                      child: Text(
                        'Universidad Nacional de Loja',
                        style: TextStyle(
                          color: AdaptiveTheme.of(context)
                              .theme
                              .primaryTextTheme
                              .titleSmall!
                              .color,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: mapController,
                    options: const MapOptions(
                      initialCenter: _unl,
                      initialZoom: 14.0,
                      maxZoom: 20.0,
                      minZoom: 3.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      ),
                      MarkerLayer(markers: _markers),
                    ],
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Column(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: _zoomIn,
                        ),
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: _zoomOut,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
