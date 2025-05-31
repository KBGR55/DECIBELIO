class QualitativeScaleValueDTO {
  final String name;

  QualitativeScaleValueDTO({required this.name});

  factory QualitativeScaleValueDTO.fromMap(Map<String, dynamic> map) {
    return QualitativeScaleValueDTO(
      name: map['name'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
    };
  }
}
