 import 'package:decibelio_app_web/models/noise_measurement.dart';
import 'package:decibelio_app_web/models/respuesta_generica.dart';

class ListNoiseMeasurementDTO extends RespuestaGenerica {
  late List<NoiseMeasurement> data = [];

  ListNoiseMeasurementDTO();

  ListNoiseMeasurementDTO.fromMap(List<dynamic> datos, String status) {
    for (var item in datos) {
      Map<String, dynamic> mapa = item as Map<String, dynamic>;
      NoiseMeasurement aux = NoiseMeasurement.fromMap(mapa);
      data.add(aux);
    }
    message = message;
    this.status = status;
  }

  @override
  String toString() {
    return 'ListNoiseMeasurementDTO{status: $status, message: $message, data: $data}';
  }
}
