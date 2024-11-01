import 'dart:convert';

class SensorDTO {
  int id = 0;
  String name = '';
  double latitude = 0.0;
  double longitude = 0.0;
  String externalId = '';
  String sensorType = '';
  String landUseName = '';
  
  SensorDTO();

  SensorDTO.fromMap(Map<dynamic, dynamic> mapa) {
    name = mapa['name'];
    id = mapa['id'];
    externalId = mapa['externalID'];
    latitude = (mapa['latitude']);
    longitude = (mapa['longitude']);
    sensorType = mapa['sensorType'];
    landUseName = mapa['landUseName'];
  }

  @override
  String toString() {
    return 'Name: $name, Id: $id, ExternalId: $externalId, Latitude: $latitude, Longitude: $longitude, SensorType: $sensorType, LandUse: $landUseName';}

  static Map<String, dynamic> toMap(SensorDTO model) => <String, dynamic>{
        "name": model.name,
        "id": model.id,
        "externalId": model.externalId,
        "latitude": model.latitude,
        "longitude": model.longitude,
        "sensorType": model.sensorType,
        "landUse": model.landUseName
      };
  static String serialize(SensorDTO model) => json.encode(SensorDTO.toMap(model));
}
