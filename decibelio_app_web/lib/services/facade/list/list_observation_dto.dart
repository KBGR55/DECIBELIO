import 'package:decibelio_app_web/models/observation.dart';
import 'package:decibelio_app_web/models/respuesta_generica.dart';

class ListMetricDTO extends RespuestaGenerica {
  late List<Observation> data = [];

  ListMetricDTO();

  ListMetricDTO.fromMap(List<dynamic> datos, String status) {
    for (var item in datos) {
      Map<String, dynamic> mapa = item as Map<String, dynamic>;
      Observation aux = Observation.fromMap(mapa);
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
