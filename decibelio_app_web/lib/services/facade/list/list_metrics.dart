import 'package:decibelio_app_web/models/metrics.dart';
import 'package:decibelio_app_web/models/respuesta_generica.dart';

class ListMetrics extends RespuestaGenerica {
  late List<Metrics> data = [];

  ListMetrics();

  ListMetrics.fromMap(List<dynamic> datos, String status) {
    for (var item in datos) {
      Map<String, dynamic> mapa = item as Map<String, dynamic>;
      Metrics aux = Metrics.fromMap(mapa);
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
