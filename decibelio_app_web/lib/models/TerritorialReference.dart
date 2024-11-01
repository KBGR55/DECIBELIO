import 'dart:convert';

class TerritorialReference {
  int id = 0;
  String county = '';
  String city='';
  String parish='';
  String locality='';
  String street='';

  TerritorialReference();

  TerritorialReference.fromMap(Map<dynamic, dynamic> mapa) {
    id = mapa['id'];
    county = mapa['county'];
    city = mapa['city'];
    parish = mapa['parish'];
    locality = mapa['locality'];
    street = mapa['street'];
  }

  @override
  String toString() {
    return 'Id: $id, County: $county, City: $city, Parish: $parish, Locality: $locality, Street: $street';}

  static Map<String, dynamic> toMap(TerritorialReference model) => <String, dynamic>{
        "id": model.id,
        "county": model.county,
        "city": model.city,
        "parish": model.parish,
        "locality": model.locality,
        "street": model.street
      };
  static String serialize(TerritorialReference model) =>
      json.encode(TerritorialReference.toMap(model));
}
