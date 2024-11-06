import 'dart:convert';

class GeoLocation {
  double latitude;  // Cambiar a double para que coincida con el modelo de Java
  double longitude; // Cambiar a double para que coincida con el modelo de Java

  GeoLocation({required this.latitude, required this.longitude});

  GeoLocation.fromMap(Map<String, dynamic> map) 
    : latitude = map['latitude'].toDouble(), // Asegúrate de que sea un double
      longitude = map['longitude'].toDouble(); // Asegúrate de que sea un double

  @override
  String toString() {
    return 'GeoLocation(latitude: $latitude, longitude: $longitude)';
  }

  static Map<String, dynamic> toMap(GeoLocation model) => <String, dynamic>{
    "latitude": model.latitude,
    "longitude": model.longitude,
  };

  static String serialize(GeoLocation model) => json.encode(GeoLocation.toMap(model));
}