class RoleDTO {
  final int id;
  final String type;

  RoleDTO({required this.id, required this.type});

  factory RoleDTO.fromJson(Map<String, dynamic> json) {
    return RoleDTO(
      id: json['id'] as int,
      type: json['type'] as String,
    );
  }
}