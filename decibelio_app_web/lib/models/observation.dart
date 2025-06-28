import 'dart:convert';
import 'package:decibelio_app_web/models/geo_location.dart';
import 'package:decibelio_app_web/models/qualitative_scale_value_dto.dart';
import 'package:decibelio_app_web/models/quantity.dart';
import 'package:decibelio_app_web/models/time_frame_dto.dart';

class Observation {
  final String? date;  // String representando LocalDate
  final GeoLocation geoLocation;
  final int id;
  final QualitativeScaleValueDTO qualitativeScaleValue;
  final QuantityDTO quantity;
  final String sensorExternalId;
  final TimeFrameDTO timeFrame;

  Observation({
    required this.date,
    required this.geoLocation,
    required this.id,
    required this.qualitativeScaleValue,
    required this.quantity,
    required this.sensorExternalId,
    required this.timeFrame,
  });

  factory Observation.fromMap(Map<String, dynamic> map) {
    return Observation(
      date: map['date'] as String,
      geoLocation: GeoLocation.fromMap(map['geoLocation'] as Map<String, dynamic>),
      id: map['id'] as int,
      qualitativeScaleValue: QualitativeScaleValueDTO.fromMap(
        map['qualitativeScaleValue'] as Map<String, dynamic>,
      ),
      quantity: QuantityDTO.fromMap(map['quantity'] as Map<String, dynamic>),
      sensorExternalId: map['sensorExternalId'] as String,
      timeFrame: TimeFrameDTO.fromMap(map['timeFrame'] as Map<String, dynamic>),
    );
  }

  @override
  String toString() {
    return 'Observation('
        'id: $id, '
        'date: $date, '
        'geoLocation: $geoLocation, '
        'qualitativeScaleValue: ${qualitativeScaleValue.name}, '
        'quantity(time: ${quantity.time}, value: ${quantity.value}), '
        'sensorExternalId: $sensorExternalId, '
        'timeFrame(name: ${timeFrame.name}, start: ${timeFrame.startTime}, end: ${timeFrame.endTime})'
        ')';
  }

  static Map<String, dynamic> toMap(Observation obs) => <String, dynamic>{
        'date': obs.date,
        'geoLocation': GeoLocation.toMap(obs.geoLocation),
        'id': obs.id,
        'qualitativeScaleValue': obs.qualitativeScaleValue.toMap(),
        'quantity': obs.quantity.toMap(),
        'sensorExternalId': obs.sensorExternalId,
        'timeFrame': obs.timeFrame.toMap(),
      };

  static String serialize(Observation obs) => json.encode(Observation.toMap(obs));
}
