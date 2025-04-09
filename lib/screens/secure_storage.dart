import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  // Sauvegarder le token
  Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  // Récupérer le token
  Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  // Supprimer le token
  Future<void> deleteToken() async {
    await _storage.delete(key: 'auth_token');
  }
}
