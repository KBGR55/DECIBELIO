import 'dart:convert';

class SensorStatus {
  String sensorStatus = '';


  SensorStatus();

  SensorStatus.fromMap(Map<dynamic, dynamic> mapa) {
    sensorStatus = mapa['SensorStatus'];
  }

  @override
  String toString() {
    return 'SensorStatus: $sensorStatus';
  }

  static Map<String, dynamic> toMap(SensorStatus model) => <String, dynamic>{
        "nombre": model.sensorStatus,
      };
  static String serialize(SensorStatus model) => json.encode(SensorStatus.toMap(model));
}
