import 'dart:convert';
import 'package:decibelio_app_web/models/GeoLocation.dart';

class Metric {
  final String date; // Debería ser LocalDate en Java, pero se puede usar String aquí
  final String time; // Debería ser LocalTime en Java, pero se puede usar String aquí
  final GeoLocation geoLocation;
  final int id; // Cambiar a int para que coincida con el modelo de Java
  final String? range; // Puede ser nulo según el modelo de Java
  final String sensorExternalId; // Este es un String en Java
  final double value; // Este es un float en Java

  Metric({
    required this.date,
    required this.geoLocation,
    required this.id,
    this.range, // Hacerlo opcional
    required this.sensorExternalId,
    required this.time,
    required this.value,
  });

  factory Metric.fromMap(Map<String, dynamic> map) {
    return Metric(
      date: map['date'],
      geoLocation: GeoLocation.fromMap(map['geoLocation']),
      id: map['id'],
      range: map['range'], // Puede ser nulo
      sensorExternalId: map['sensorExternalId'],
      time: map['time'],
      value: map['value'].toDouble(), // Asegúrate de que esto se convierta a double
    );
  }

  @override
  String toString() {
    return 'Metric(id: $id, date: $date, time: $time, value: $value, geoLocation: $geoLocation, range: $range, sensorExternalId: $sensorExternalId)';
  }
}