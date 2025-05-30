import 'package:decibelio_app_web/models/observations.dart';
import 'package:decibelio_app_web/models/respuesta_generica.dart';

class ListMetrics extends RespuestaGenerica {
  late List<Observations> data = [];

  ListMetrics();

  ListMetrics.fromMap(List<dynamic> datos, String status) {
    for (var item in datos) {
      Map<String, dynamic> mapa = item as Map<String, dynamic>;
      Observations aux = Observations.fromMap(mapa);
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
