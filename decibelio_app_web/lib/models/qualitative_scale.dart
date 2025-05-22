
class QualitativeScaleDTO {
  final String name;
  final String? description;

  QualitativeScaleDTO({required this.name, this.description});

  factory QualitativeScaleDTO.fromMap(Map<String, dynamic> map) {
    return QualitativeScaleDTO(
      name: map['name'] ?? '',
      description: map['description'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
    };
  }
}
