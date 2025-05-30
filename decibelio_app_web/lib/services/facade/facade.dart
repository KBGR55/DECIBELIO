import 'dart:convert';
import 'package:decibelio_app_web/services/conexion.dart';
import 'package:decibelio_app_web/services/facade/list/list_metric_dto.dart';
import 'package:decibelio_app_web/services/facade/list/list_metrics.dart';
import 'package:decibelio_app_web/services/facade/list/list_sensor_dto.dart';

class Facade {
  final Conexion _conn = Conexion();
  Future<ListSensorDTO> listSensorDTO() async {
    var response = await _conn.solicitudGet('sensors/active', "NO");
    return _responseSensor(
        (response.status != 'SUCCESS') ? null : response.payload);
  }

  Future<ListSensorDTO> listAllSensorsDTO() async {
    var response = await _conn.solicitudGet('sensors', "NO");
    return _responseSensor(
        (response.status != 'SUCCESS') ? null : response.payload);
  }

  Future<ListMetricDTO> listMetricLastDTO() async {
    var response = await _conn.solicitudGet('observation/last', "NO");
    var observation = _responseMetricLast(
        (response.status != 'SUCCESS') ? null : response.payload);
    return observation;
  }

  ListMetricDTO _responseMetricLast(dynamic data) {
    var sesion = ListMetricDTO();
    if (data != null) {
      Map<String, dynamic> mapa = jsonDecode(data);
      if (mapa.containsKey("payload")) {
        List datos = jsonDecode(jsonEncode(mapa["payload"]));

        sesion = ListMetricDTO.fromMap(datos, mapa["status"].toString());
      } else {
        List myList = List.empty();
        sesion = ListMetricDTO.fromMap(myList, mapa["status"].toString());
      }
    }
    return sesion;
  }

  ListSensorDTO _responseSensor(dynamic data) {
    var sesion = ListSensorDTO();
    if (data != null) {
      Map<String, dynamic> mapa = jsonDecode(data);
      if (mapa.containsKey("payload")) {
        List datos = jsonDecode(jsonEncode(mapa["payload"]));
        sesion = ListSensorDTO.fromMap(datos, mapa["status"].toString());
      } else {
        List myList = List.empty();
        sesion = ListSensorDTO.fromMap(myList, mapa["status"].toString());
      }
    }
    return sesion;
  }

  Future<ListMetrics> listMetrics(dynamic data) async {
    var response = await _conn.solicitudPost('observation/sensor', data, "NO");
    var observation = _responseMetrics(
        (response.status != 'SUCCESS') ? null : response.payload);
    return observation;
  }

  ListMetrics _responseMetrics(dynamic data) {
    var sesion = ListMetrics();
    Map<String, dynamic> mapa = jsonDecode(data);
    if (mapa.containsKey("payload")) {
      // Decodificar la lista de payload
      List datos = jsonDecode(jsonEncode(mapa["payload"]));

      // Acceder al primer elemento de "payload" y extraer "observation"
      if (datos.isNotEmpty && datos[0].containsKey("observation")) {
        List observation = datos[0]["observation"];

        // Puedes convertirlo directamente a tu modelo si es necesario
        sesion = ListMetrics.fromMap(observation, mapa["status"].toString());
      } else {
        List myList = List.empty();
        sesion = ListMetrics.fromMap(myList, mapa["status"].toString());
      }
    }
    return sesion;
  }
}
