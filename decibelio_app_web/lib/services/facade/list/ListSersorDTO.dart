import 'package:decibelio_app_web/models/RespuestaGenerica.dart';
import 'package:decibelio_app_web/models/SensorDTO.dart';

class ListSensorDTO extends RespuestaGenerica {
  late List<SensorDTO> data = [];

  ListSensorDTO();
  
  ListSensorDTO.fromMap(List datos, String status) {
    datos.forEach((item) {
      Map<dynamic, dynamic> mapa = item;
      SensorDTO aux = SensorDTO.fromMap(mapa);
      data.add(aux);
    });
    this.message = message; // Make sure message is defined
    this.status = status;
  }

  @override
  String toString() {
    return 'ListSensorDTO{status: $status, message: $message, data: $data}';
  }
}
