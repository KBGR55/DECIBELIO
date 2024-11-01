import 'dart:convert';
import 'package:decibelio_app_web/services/conexion.dart';
import 'package:decibelio_app_web/services/facade/list/ListSersorDTO.dart';

class Facade {
  conexion _conn = new conexion();
  Future<ListSensorDTO> listSensorDTO() async {
    var response = await _conn.solicitudGet('sensors/active', "NO");
   return _responseSensor(
        (response.status != 'SUCCESS') ? null : response.payload);
  }
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
