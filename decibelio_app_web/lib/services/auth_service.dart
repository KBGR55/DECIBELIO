// lib/services/auth_service.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static const _s = FlutterSecureStorage();
  static const _kToken = 'jwt', _kRoles = 'roles', _kName = 'name';

  static Future<void> save(
      String jwt, List<String> roles, String fullName) async {
    await _s.write(key: _kToken, value: jwt);
    await _s.write(key: _kRoles, value: roles.join(','));
    await _s.write(key: _kName, value: fullName);
  }

  static Future<String?> token() => _s.read(key: _kToken);
  static Future<List<String>> roles() async =>
      (await _s.read(key: _kRoles))?.split(',') ?? [];
  static Future<String?> fullName() => _s.read(key: _kName);

  static Future<void> clear() => _s.deleteAll();
}