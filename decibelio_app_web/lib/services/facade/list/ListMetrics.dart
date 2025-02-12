import 'package:decibelio_app_web/models/Metric.dart';
import 'package:decibelio_app_web/models/Metrics.dart';
import 'package:decibelio_app_web/models/RespuestaGenerica.dart';

class ListMetrics extends RespuestaGenerica {
  late List<Metrics> data = [];

  ListMetrics();

  ListMetrics.fromMap(List<dynamic> datos, String status) {
    datos.forEach((item) {
      Map<String, dynamic> mapa = item as Map<String, dynamic>;
      Metrics aux = Metrics.fromMap(mapa);
      data.add(aux);
    });
    this.message = message;
    this.status = status;
  }

  @override
  String toString() {
    return 'ListMetricDTO{status: $status, message: $message, data: $data}';
  }
}
