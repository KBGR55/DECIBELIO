import 'dart:convert';


class LandUse {
  int id = 0;
  String name = '';
  String description = '';
  LandUse();

  LandUse.fromMap(Map<dynamic, dynamic> mapa) {
    name = mapa['name'];
    id = mapa['id'];
    description = mapa['description'];
  }

  @override
  String toString() {
    return 'Name: $name, Id: $id, Description: $description';
  }

  static Map<String, dynamic> toMap(LandUse model) => <String, dynamic>{
        "name": model.name,
        "id": model.id,
        "description": model.description
      };
  static String serialize(LandUse model) => json.encode(LandUse.toMap(model));
}
