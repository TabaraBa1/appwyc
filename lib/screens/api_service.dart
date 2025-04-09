import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiService {
  final String baseUrl =
      "https://floating-sea-30778-fbe8564bd579.herokuapp.com/api";
  final String adminEmail = "tabara@gmail.com";
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  Future<String?> getToken() async {
    return await _storage.read(key: 'token');
  }

  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      final errorResponse = jsonDecode(response.body);
      throw Exception(
        'Failed to register: ${errorResponse['message'] ?? response.body}',
      );
    }
  }

  Future<Map<String, dynamic>> sendVerificationCode(
    String name,
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/send-verification-code'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      final errorResponse = jsonDecode(response.body);
      throw Exception(
        'Failed to send verification code: ${errorResponse['message'] ?? response.body}',
      );
    }
  }

  /// Connexion d'un utilisateur
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to login');
    }
  }

  /// Méthode pour notifier l'administrateur
  Future<void> notifyAdmin(String name, String email) async {
    try {
      // Utilisez votre méthode d'envoi d'email ici
      final response = await http.post(
        Uri.parse('$baseUrl/notify-admin'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'adminEmail': adminEmail,
          'message': 'Nouvel utilisateur enregistré: $name, Email: $email',
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to notify admin');
      }
    } catch (e) {
      print('Error notifying admin: $e');
      throw Exception('Error notifying admin: $e');
    }
  }

  Future<Map<String, dynamic>> verifyCode(String email, String code) async {
    final response = await http.post(
      Uri.parse('$baseUrl/verify-code'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'code': code}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
        'Erreur lors de la vérification du code : ${response.body}',
      );
    }
  }

  Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String email,
    String? profileImagePath,
  }) async {
    final token = await getToken();

    // Préparez les données du formulaire
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/user/update-profile'),
    );
    request.headers['Authorization'] = 'Bearer $token';
    request.fields['name'] = name;
    request.fields['email'] = email;

    // Ajoutez la photo de profil si elle est fournie
    if (profileImagePath != null) {
      request.files.add(
        await http.MultipartFile.fromPath('profile_image', profileImagePath),
      );
    }

    // Envoyez la requête
    final response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      return jsonDecode(responseBody);
    } else {
      throw Exception('Failed to update profile');
    }
  }

  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    final token = await getToken();

    final response = await http.post(
      Uri.parse('$baseUrl/user/update-password'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'current_password': currentPassword,
        'new_password': newPassword,
        'new_password_confirmation': newPasswordConfirmation,
      }),
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to update password');
    }
  }

  Future<Map<String, dynamic>> getUserProfile() async {
    final token = await getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/user/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to fetch user profile');
    }
  }

  Future<Map<String, dynamic>> sendPasswordResetLink(String email) async {
    final response = await http.post(
      Uri.parse('$baseUrl/password/reset'),
      body: {'email': email},
    );

    if (response.statusCode == 200) {
      return json.decode(response.body); // Réponse JSON de l'API
    } else {
      throw Exception('Erreur lors de l\'envoi du lien de réinitialisation.');
    }
  }
}
