import 'package:decibelio_app_web/models/Metric.dart';
import 'package:decibelio_app_web/models/RespuestaGenerica.dart';
import 'package:decibelio_app_web/models/SensorDTO.dart';

class ListMetricDTO extends RespuestaGenerica {
  late List<Metric> data = [];

  ListMetricDTO();
  
ListMetricDTO.fromMap(List<dynamic> datos, String status) {
  datos.forEach((item) {
    Map<String, dynamic> mapa = item as Map<String, dynamic>; // Ensure correct type
    Metric aux = Metric.fromMap(mapa);
    data.add(aux);
  });
  this.message = message; // Ensure message is defined
  this.status = status;
}

  @override
  String toString() {
    return 'ListMetricDTO{status: $status, message: $message, data: $data}';
  }
}
