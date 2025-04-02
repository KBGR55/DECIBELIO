import 'dart:convert';

import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:decibelio_app_web/models/sensor_dto.dart';
import 'package:decibelio_app_web/services/conexion.dart';
import 'package:decibelio_app_web/services/facade/facade.dart';
import 'package:decibelio_app_web/services/facade/list/list_sensor_dto.dart';
import 'package:decibelio_app_web/views/sensor_create/components/sensor_create.dart';
import 'package:decibelio_app_web/views/sensor_edit/components/sensor_edit.dart';
import 'package:flutter/material.dart';
import '../../../../constants.dart';

class SensorTable extends StatefulWidget {
  final String searchQuery; // Recibe la búsqueda desde afuera

  const SensorTable({super.key, required this.searchQuery});

  @override
  State<SensorTable> createState() => _SensorTable();
}

class _SensorTable extends State<SensorTable> {
  List<SensorDTO> _sensors = [];

  @override
  void initState() {
    super.initState();
    loadSensorList();
  }

  Future<void> loadSensorList() async {
    Facade facade = Facade();
    ListSensorDTO sensorData = await facade.listAllSensorsDTO();

    setState(() {
      _sensors = sensorData.data;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Filtramos en base a widget.searchQuery
    final query = widget.searchQuery.toLowerCase();

    final filteredSensors = _sensors.where((sensor) {

      final name = sensor.name.toLowerCase();
      final type = sensor.sensorType.toLowerCase();
      final landUse = utf8.decode(sensor.landUseName.runes.toList()).toLowerCase();
      final external = sensor.externalId.toLowerCase();

      return name.contains(query) ||
          type.contains(query) ||
          landUse.contains(query) ||
          external.contains(query);
    }).toList();

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

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Lista de Sensores",
                style: Theme.of(context).textTheme.titleMedium,
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                    side: BorderSide.none,
                  ),
                  elevation: 0,
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: defaultPadding,
                    vertical: 15,
                  ),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return const AlertDialog(
                        content: SensorCreateControllerPage(
                          title: "Create Sensor",
                          color: Colors.greenAccent,
                        ),
                      );
                    },
                  );
                },
                child: const Text('Agregar Sensor +'),
              )
            ],
          ),
          SizedBox(
            width: double.infinity,
            child: DataTable(
              columnSpacing: defaultPadding,
              columns: const [
                DataColumn(label: Text("Nombre")),
                DataColumn(label: Text("External ID")),
                DataColumn(label: Text("Tipo")),
                DataColumn(label: Text("Uso de Suelo")),
                DataColumn(label: Text("Acciones")),
              ],
              // En vez de _sensors, ahora usamos filteredSensors
              rows: List.generate(
                filteredSensors.length,
                    (index) => sensorsDataRow(filteredSensors[index], context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


DataRow sensorsDataRow(SensorDTO sensor, BuildContext context) {
  return DataRow(
    cells: [
      DataCell(
        Row(
          children: [
            const Icon(Icons.sensors),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
              child: Text(sensor.name),
            ),
          ],
        ),
      ),
      DataCell(Text(sensor.externalId)),
      DataCell(Text(sensor.sensorType)),
      DataCell(Text(utf8.decode(sensor.landUseName.runes.toList()))),
      DataCell(
        Row(
          children: [
            Tooltip(
              message: "Edit",
              child: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          content: SensorEditControllerPage(
                            title: "Editar Sensor",
                            color: Colors.greenAccent,
                            sensor: sensor,
                          ),
                        );
                      });
                },
              ),
            ),
            SensorSwitch(
              initialStatus: sensor.sensorStatus == 'ACTIVE',
              sensorId: sensor.id,
            ),
          ],
        ),
      ),
    ],
  );
}

class SensorSwitch extends StatefulWidget {
  final bool initialStatus;
  final int sensorId;

  const SensorSwitch(
      {super.key, required this.initialStatus, required this.sensorId});

  @override
  SensorSwitchState createState() => SensorSwitchState();
}

class SensorSwitchState extends State<SensorSwitch> {
  late bool status;

  @override
  void initState() {
    super.initState();
    status = widget.initialStatus;
  }

  final Conexion _con = Conexion();

  Future<void> _modifyStatusSensor() async {
    final respuesta = await _con.solicitudPatch(
        'sensors/status/${widget.sensorId}', null, Conexion.noToken);
    if (respuesta.status == 'SUCCESS' && mounted) {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ), content: Row(children: [
              const Icon(Icons.check_circle, color: Colors.blue, size: 30),
              const SizedBox(width: 10),
              Text(respuesta.message)
            ],));
          });
    } else if(mounted){
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),content: const Row(children: [
              Icon(Icons.check_circle, color: Colors.red, size: 30),
              SizedBox(width: 10),
              Text('No se ha podido completar la acción')
            ],));
          });
      setState(() {
        !status;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: "Estado",
      child: Switch(
        value: status,
        activeColor: Colors.blue,
        onChanged: (bool value) {
          setState(() {
            _modifyStatusSensor();
            status = value;
          });
        },
      ),
    );
  }
}
