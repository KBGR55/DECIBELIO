import 'package:decibelio_app_web/services/conexion.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SensorCreateControllerPage extends StatefulWidget {

  const SensorCreateControllerPage({super.key, required this.title, required this.color});

  final String title;
  final Color color;

  @override
  _SensorCreateControllerPageState createState() =>
      _SensorCreateControllerPageState();
}

class _SensorCreateControllerPageState
    extends State<SensorCreateControllerPage> {
  GlobalKey<ScaffoldState> sensorScreenKey = GlobalKey<ScaffoldState>();
  final conexion _con = conexion();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _externalIdController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final MapController _mapController = MapController(); 

  String _selectedSensorType = 'SOUND_LEVEL_METER';
  String _selectedSensorStatus = 'ACTIVE';
  String _selectedLandUse = '1';

  // Coordenadas iniciales centradas en Loja, Ecuador
  LatLng _selectedLocation = LatLng(-3.99313, -79.20422);
  double _currentZoom = 12.0; // Agregar nivel de zoom actual

  // Función para aumentar el zoom
  void _zoomIn() {
    setState(() {
      if (_currentZoom < 18.0) {
        // Verificar el zoom máximo
        _currentZoom++;
        _mapController.move(_selectedLocation, _currentZoom);
      }
    });
  }

  // Función para disminuir el zoom
  void _zoomOut() {
    setState(() {
      if (_currentZoom > 5.0) {
        // Verificar el zoom mínimo
        _currentZoom--;
        _mapController.move(_selectedLocation, _currentZoom);
      }
    });
  }

  Future<void> _agregarSensor() async {
    if (_formKey.currentState!.validate()) {
      Map<String, dynamic> data = {
        "name": _nameController.text,
        "externalId": _externalIdController.text,
        "latitude": _selectedLocation.latitude,
        "longitude": _selectedLocation.longitude,
        "sensorType": _selectedSensorType,
        "sensorStatus": _selectedSensorStatus,
        "landUseID": int.parse(_selectedLandUse),
      };

      final respuesta =
          await _con.solicitudPost('sensors/create', data, conexion.NO_TOKEN);
      if (respuesta.status == "SUCCESS") {
        _nameController.clear();
        _externalIdController.clear();
        setState(() {
          _selectedSensorType = 'SOUND_LEVEL_METER';
          _selectedSensorStatus = 'ACTIVE';
          _selectedLandUse = '1';
          _selectedLocation = LatLng(-3.99313, -79.20422);
        });

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              title: Row(
                children: const [
                  Icon(Icons.check_circle, color: Colors.blue, size: 30),
                  SizedBox(width: 10),
                  Text('Sensor agregado correctamente'),
                ],
              ),
            );
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Error al agregar el sensor: ${respuesta.message}")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      content: Container(
        width: MediaQuery.of(context).size.width * 0.5,
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Agregar Sensor',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),

              // Nombre del Sensor
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nombre del Sensor',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  prefixIcon: const Icon(Icons.label),
                ),
              ),
              const SizedBox(height: 24),

              // Identificador Externo
              TextFormField(
                controller: _externalIdController,
                decoration: InputDecoration(
                  labelText: 'Identificador Externo',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  prefixIcon: const Icon(Icons.perm_identity),
                ),
              ),
              const SizedBox(height: 24),

              // Mapa con la localización
              const Text('Ubicación del Sensor',
                  style: TextStyle(fontSize: 16)),
              const SizedBox(height: 8),
              Stack(
                // Usar Stack para superponer los botones sobre el mapa
                children: [
                  SizedBox(
                    height: 250,
                    child: FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: _selectedLocation, // Cambiar a center
                        initialZoom: _currentZoom, // Usar el zoom actual
                        minZoom: 5.0,
                        maxZoom: 18.0,
                        onTap: (tapPosition, latlng) {
                          setState(() {
                            _selectedLocation = latlng;
                          });
                        },
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName:
                              'dev.fleaflet.flutter_map.example',
                          tileProvider: CancellableNetworkTileProvider(),
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              width: 35,
                              height: 35,
                              point: _selectedLocation,
                              child: GestureDetector(
                                onTap: () {},
                                child: SvgPicture.asset(
                                  'assets/icons/map-marker-svgrepo-com.svg',
                                  width: 35,
                                  height: 35,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    // Posicionar botones de zoom
                    top: 10,
                    right: 10,
                    child: Column(
                      children: [
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: _zoomIn,
                        ),
                        IconButton(
                          icon: Icon(Icons.remove),
                          onPressed: _zoomOut,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Tipo de Sensor
              DropdownButtonFormField<String>(
                value: _selectedSensorType,
                decoration: InputDecoration(
                  labelText: 'Tipo de Sensor',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'SOUND_LEVEL_METER',
                    child: Text('Sound Level Meter'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedSensorType = value!;
                  });
                },
              ),
              const SizedBox(height: 24),

              // Estado del Sensor
              DropdownButtonFormField<String>(
                value: _selectedSensorStatus,
                decoration: InputDecoration(
                  labelText: 'Estado del Sensor',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'ACTIVE', child: Text('Activo')),
                  DropdownMenuItem(
                      value: 'DESACTIVE', child: Text('Desactivado')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedSensorStatus = value!;
                  });
                },
              ),
              const SizedBox(height: 24),

              // Uso del Suelo
              DropdownButtonFormField<String>(
                value: _selectedLandUse,
                decoration: InputDecoration(
                  labelText: 'Uso de suelo',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: '1', child: Text('Residencial')),
                  DropdownMenuItem(
                      value: '2',
                      child: Text('Equipamiento de Servicios Sociales')),
                  DropdownMenuItem(
                      value: '3',
                      child: Text('Equipamiento de Servicios Públicos')),
                  DropdownMenuItem(value: '4', child: Text('Comercial')),
                  DropdownMenuItem(
                      value: '5', child: Text('Agrícola Residencial')),
                  DropdownMenuItem(
                      value: '6', child: Text('Industrial ID1/ID2')),
                  DropdownMenuItem(
                      value: '7', child: Text('Industrial ID3/ID4')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedLandUse = value!;
                  });
                },
              ),
              const SizedBox(height: 24),

              // Botones
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'Cancelar',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _agregarSensor,
                    child: const Text('Agregar Sensor'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
