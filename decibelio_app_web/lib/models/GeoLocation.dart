import 'dart:convert';
class GeoLocation {
  double latitude = 0.0;
   double longitude = 0.0;
  
  GeoLocation();

  GeoLocation.fromMap(Map<dynamic, dynamic> mapa) {
    latitude = double.parse(mapa['latitude']);
    longitude = double.parse(mapa['longitude']);
   
  }

  @override
  String toString() {
    return 'Latitude: $latitude, Longitude: $longitude';
  }

  static Map<String, dynamic> toMap(GeoLocation model) => <String, dynamic>{
        "latitude": model.latitude,
        "longitude": model.longitude,
      };
  static String serialize(GeoLocation model) => json.encode(GeoLocation.toMap(model));
}
