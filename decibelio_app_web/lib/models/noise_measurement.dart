import 'dart:convert';

// GeoLocation para almacenar latitud y longitud
class GeoLocation {
  final double latitude;
  final double longitude;

  GeoLocation({
    required this.latitude,
    required this.longitude,
  });

  factory GeoLocation.fromMap(Map<String, dynamic> map) {
    return GeoLocation(
      latitude: map['geoLatitude'] as double,
      longitude: map['geoLongitude'] as double,
    );
  }

  static Map<String, dynamic> toMap(GeoLocation location) => {
        'geoLatitude': location.latitude,
        'geoLongitude': location.longitude,
      };
}


// NoiseMeasurement simplificada
class NoiseMeasurement {
  final String timeFrame;
  final double maxValue;
  final double minValue;
  final String maxTime;
  final String minTime;
  final double avgValue;
  final String sensorExternalId;
  final GeoLocation geoLocation;
  final String startTime;
  final String endTime;

  NoiseMeasurement({
    required this.timeFrame,
    required this.maxValue,
    required this.minValue,
    required this.maxTime,
    required this.minTime,
    required this.avgValue,
    required this.sensorExternalId,
    required this.geoLocation,
    required this.startTime,
    required this.endTime,
  });

  factory NoiseMeasurement.fromMap(Map<String, dynamic> map) {
    return NoiseMeasurement(
      timeFrame: map['timeFrame'] as String,
      maxValue: map['maxValue'] as double,
      minValue: map['minValue'] as double,
      maxTime: map['startTime'] as String,
      minTime: map['endTime'] as String,
      avgValue: map['avgValue'] as double,
      startTime: map['startTime'] as String,
      endTime: map['endTime'] as String,
      sensorExternalId: map['sensorExternalId'] as String,
      geoLocation: GeoLocation.fromMap(map),
    );
  }

  @override
  String toString() {
    return 'NoiseMeasurement('
        'timeFrame: $timeFrame, '
        'maxValue: $maxValue, '
        'minValue: $minValue, '
        'maxTime: $maxTime, '
        'minTime: $minTime, '
        'avgValue: $avgValue, '
        'sensorExternalId: $sensorExternalId, '
        'startTime: $startTime, '
        'endTime: $endTime, '
        'geoLocation: $geoLocation'
        ')';
  }
  static Map<String, dynamic> toMap(NoiseMeasurement measurement) {
    return {
      'timeFrame': measurement.timeFrame,
      'maxValue': measurement.maxValue,
      'minValue': measurement.minValue,
      'maxTime': measurement.maxTime,
      'minTime': measurement.minTime,
      'avgValue': measurement.avgValue,
      'sensorExternalId': measurement.sensorExternalId,
      'startTime': measurement.startTime,
      'endTime': measurement.endTime,
      'geoLocation': GeoLocation.toMap(measurement.geoLocation),
    };
  }

  static String serialize(NoiseMeasurement measurement) => json.encode(NoiseMeasurement.toMap(measurement));

  static List<NoiseMeasurement> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((data) => NoiseMeasurement.fromMap(data as Map<String, dynamic>)).toList();
  }
}
