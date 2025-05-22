class UnitTypeDTO {
  final String name;
  final String? abbreviation;

  UnitTypeDTO({required this.name, this.abbreviation});

  factory UnitTypeDTO.fromMap(Map<String, dynamic> map) {
    return UnitTypeDTO(
      name: map['name'] ?? '',
      abbreviation: map['abbreviation'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'abbreviation': abbreviation,
    };
  }
}
