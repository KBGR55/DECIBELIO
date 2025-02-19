import 'package:decibelio_app_web/models/respuesta_generica.dart';
import 'package:decibelio_app_web/models/sensor_dto.dart';

class ListSensorDTO extends RespuestaGenerica {
  late List<SensorDTO> data = [];

  ListSensorDTO();
  
  ListSensorDTO.fromMap(List datos, String status) {
    for (var item in datos) {
      Map<dynamic, dynamic> mapa = item;
      SensorDTO aux = SensorDTO.fromMap(mapa);
      data.add(aux);
    }
    message = message; // Make sure message is defined
    this.status = status;
  }

  @override
  String toString() {
    return 'ListSensorDTO{status: $status, message: $message, data: $data}';
  }
}
