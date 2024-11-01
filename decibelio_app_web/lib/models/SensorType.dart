import 'dart:convert';

class SensorType {
  String name = '';


  SensorType();

  SensorType.fromMap(Map<dynamic, dynamic> mapa) {
    name = mapa['SensorType'];

  }

  @override
  String toString() {
    return 'Name: $name';
  }

  static Map<String, dynamic> toMap(SensorType model) => <String, dynamic>{
        "nombre": model.name,
      };
  static String serialize(SensorType model) => json.encode(SensorType.toMap(model));
}
