import 'package:decibelio_app_web/services/facade/list/ListMetricDTO.dart';
import 'package:decibelio_app_web/services/facade/list/ListSersorDTO.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:latlong2/latlong.dart';
import 'package:decibelio_app_web/services/facade/facade.dart';

class AnimatedMapControllerPage extends StatefulWidget{
  static const String route = '/map_controller_animated';
  const AnimatedMapControllerPage({super.key, required this.title, required this.color});

  final String title;
  final Color color;
  

  @override
  AnimatedMapControllerPageState createState() =>
      AnimatedMapControllerPageState();
}

class AnimatedMapControllerPageState extends State<AnimatedMapControllerPage>
    with TickerProviderStateMixin {

  GlobalKey<ScaffoldState> mapScreenKey = GlobalKey<ScaffoldState>();
  static const _paris = LatLng(-4.032126227155394, -79.20267644603182);
  static const _loja = LatLng(-3.99313, -79.20422);
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

  void _fetchSensors() async {
    try {
      ListSensorDTO sensorData = await _facade.listSensorDTO();
      if (sensorData.status == 'SUCCESS') {
         ListMetricDTO metricLastData= await _facade.listMetricLastDTO();
        setState(() {
          sensors = sensorData;
          metricLast = metricLastData;
          _populateMarkers();
        });
        print("Metrcis fetched: $metricLast");
        print("Sensors fetched: $sensors");

      } else {
        print("Failed to fetch sensors: ${sensorData.message}");
      }
    } catch (e) {
      print("Error fetching sensors: $e");
    }
  }

 void _populateMarkers() {
  _markers.clear();
  if (sensors != null && sensors!.data.isNotEmpty) {
    for (var sensor in sensors!.data) {
      Marker marker = Marker(
        width: 35,
        height: 35,
        point: LatLng(sensor.latitude, sensor.longitude),
        child: GestureDetector(
          onTap: () {
            String? value;
            String? date;
            String? time;

            // Buscar la métrica correspondiente al sensor
            if (metricLast != null) {
              for (var metric in metricLast!.data) {
                if (metric.sensorExternalId == sensor.externalId) {
                  value = metric.value.toString();
                  date = metric.date; // Obtener la fecha
                  time = metric.time; // Obtener la hora
                  break;
                }
              }
            }

            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text(sensor.name),
                  content: Text(
                    'Tipo de sensor: ${sensor.sensorType}\n'
                    'Valor: ${value ?? 'No disponible'}\n'
                    'Fecha: ${date ?? 'No disponible'}\n'
                    'Hora: ${time ?? 'No disponible'}',
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
          child: SvgPicture.asset(
            'assets/icons/map-marker-svgrepo-com.svg',
            width: 35,
            height: 35,
          ),
        ),
      );
      _markers.add(marker);
    }
  } else {
    print("No sensors available or sensors data is null.");
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
                  child: const Text('Loja'),
                ),
                MaterialButton(
                  onPressed: () => _animatedMapMove(_paris, 15),
                  child: const Text('Universidad Nacional de Loja'),
                ),
              ],
            ),
          ),
          Flexible(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    initialCenter: _loja,
                    initialZoom: 15.0,
                    maxZoom: 20.0,
                    minZoom: 3.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
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