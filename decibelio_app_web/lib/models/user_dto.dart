// lib/models/user_dto.dart

class UserDTO {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String photo;
  final List<String> roles;
  final bool status;

  UserDTO({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.photo,
    required this.roles,
    required this.status,
  });

  factory UserDTO.fromJson(Map<String, dynamic> json) {
    return UserDTO(
      id: json['id'] as int,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
      photo: (json['photo'] as String?) ?? '',
      roles: List<String>.from(json['roles'] as List<dynamic>),
      status: json['status'] as bool,
    );
  }
}
