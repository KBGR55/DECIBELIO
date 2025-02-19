import 'package:decibelio_app_web/models/metric.dart';
import 'package:decibelio_app_web/models/respuesta_generica.dart';

class ListMetricDTO extends RespuestaGenerica {
  late List<Metric> data = [];

  ListMetricDTO();
  
ListMetricDTO.fromMap(List<dynamic> datos, String status) {
  for (var item in datos) {
    Map<String, dynamic> mapa = item as Map<String, dynamic>; 
    Metric aux = Metric.fromMap(mapa);
    data.add(aux);
  }
  message = message; 
  this.status = status;
}

  @override
  String toString() {
    return 'ListMetricDTO{status: $status, message: $message, data: $data}';
  }
}
