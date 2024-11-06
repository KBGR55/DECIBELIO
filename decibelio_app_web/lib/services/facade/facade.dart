import 'dart:convert';
import 'package:decibelio_app_web/services/conexion.dart';
import 'package:decibelio_app_web/services/facade/list/ListMetricDTO.dart';
import 'package:decibelio_app_web/services/facade/list/ListSersorDTO.dart';

class Facade {
  conexion _conn = new conexion();
  Future<ListSensorDTO> listSensorDTO() async {
    var response = await _conn.solicitudGet('sensors/active', "NO");
    return _responseSensor(
        (response.status != 'SUCCESS') ? null : response.payload);
  }

Future<ListMetricDTO> listMetricLastDTO() async {
  var response = await _conn.solicitudGet('metrics/last', "NO");
   print("Metrics API response: ${response.status}"); 
  var metrics = _responseMetricLast((response.status != 'SUCCESS') ? null : response.payload);
  print("Metrics fetched: $metrics"); // Imprime el contenido de ListMetricDTO
  return metrics;
}

  ListMetricDTO _responseMetricLast(dynamic data) {
    var sesion = ListMetricDTO();
    if (data != null) {
       print("Data: ${data}"); 
      Map<String, dynamic> mapa = jsonDecode(data);
      if (mapa.containsKey("payload")) {
        
        List datos = jsonDecode(jsonEncode(mapa["payload"]));
 print("Datos: ${datos}"); 
    
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
}
