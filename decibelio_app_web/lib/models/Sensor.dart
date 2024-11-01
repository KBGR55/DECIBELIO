import 'dart:convert';

import 'package:decibelio_app_web/models/GeoLocation.dart';
import 'package:decibelio_app_web/models/LandUse.dart';
import 'package:decibelio_app_web/models/SensorStatus.dart';
import 'package:decibelio_app_web/models/SensorType.dart';
import 'package:decibelio_app_web/models/TerritorialReference.dart';

class Sensor {
  int id = 0;
  String name = '';
  SensorType sensorType = SensorType();
  SensorStatus sensorStatus = SensorStatus();
  GeoLocation geoLocation = GeoLocation();
  String externalId = '';
  LandUse landUse = LandUse();
  TerritorialReference territorialReference = TerritorialReference();

  Sensor();

  Sensor.fromMap(Map<dynamic, dynamic> mapa) {
    name = mapa['name'];
    id = mapa['id'];
    externalId = mapa['externalId'];
    sensorType = SensorType.fromMap(mapa['sensorType']);
    sensorStatus = SensorStatus.fromMap(mapa['sensorStatus']);
    geoLocation = GeoLocation.fromMap(mapa['geoLocation']['GeoLocation']);
    landUse = LandUse.fromMap(mapa['landUse']['LandUse']);
    territorialReference = TerritorialReference.fromMap(mapa['territorialReference']['TerritorialReference']);
  }

  @override
  String toString() {
    return 'Name: $name, Id: $id, ExternalId: $externalId, SensorType: $sensorType, SensorStatus: $sensorStatus, GeoLocation: $geoLocation, LandUse: $landUse, TerritorialReference: $territorialReference';
  }

  static Map<String, dynamic> toMap(Sensor model) => <String, dynamic>{
        "name": model.name,
        "id": model.id,
        "externalId": model.externalId,
        "sensorType": SensorType.toMap(model.sensorType),
        "sensorStatus": SensorStatus.toMap(model.sensorStatus),
        "geoLocation": GeoLocation.toMap(model.geoLocation),
        "landUse": LandUse.toMap(model.landUse),
        "territorialReference": TerritorialReference.toMap(model.territorialReference)
      };
  static String serialize(Sensor model) => json.encode(Sensor.toMap(model));
}
