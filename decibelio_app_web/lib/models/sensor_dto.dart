import 'dart:convert';

import 'package:decibelio_app_web/models/qualitative_scale.dart';
import 'package:decibelio_app_web/models/unit_type.dart';

class SensorDTO {
  int id = 0;
  String name = '';
  double latitude = 0.0;
  double longitude = 0.0;
  String externalId = '';
  String sensorType = '';
  String sensorStatus = '';
  String landUseName = '';

  UnitTypeDTO? unitType;
  List<QualitativeScaleDTO> qualitativeScales = [];

  SensorDTO();

  SensorDTO.fromMap(Map<dynamic, dynamic> mapa) {
    name = mapa['name'] ?? '';
    id = mapa['id'] ?? 0;
    externalId = mapa['externalID'] ?? '';
    latitude = (mapa['latitude'] ?? 0.0).toDouble();
    longitude = (mapa['longitude'] ?? 0.0).toDouble();
    sensorType = mapa['sensorType'] ?? '';
    sensorStatus = mapa['sensorStatus'] ?? 'NO INFO';
    landUseName = mapa['landUseName'] ?? '';

    if (mapa['unitType'] != null) {
      unitType = UnitTypeDTO.fromMap(Map<String, dynamic>.from(mapa['unitType']));
    }

    if (mapa['qualitativeScale'] != null) {
      qualitativeScales = List<Map<String, dynamic>>.from(mapa['qualitativeScale'])
          .map((e) => QualitativeScaleDTO.fromMap(e))
          .toList();
    }
  }

  @override
  String toString() {
    return 'Name: $name, Id: $id, ExternalId: $externalId, Latitude: $latitude, Longitude: $longitude, SensorType: $sensorType, SensorStatus: $sensorStatus, LandUse: $landUseName, UnitType: $unitType, QualitativeScales: $qualitativeScales';
  }

  static Map<String, dynamic> toMap(SensorDTO model) => <String, dynamic>{
        "name": model.name,
        "id": model.id,
        "externalId": model.externalId,
        "latitude": model.latitude,
        "longitude": model.longitude,
        "sensorType": model.sensorType,
        "sensorStatus": model.sensorStatus,
        "landUse": model.landUseName,
        "unitType": model.unitType?.toMap(),
        "qualitativeScale": model.qualitativeScales.map((e) => e.toMap()).toList(),
      };

  static String serialize(SensorDTO model) => json.encode(SensorDTO.toMap(model));
}
