import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  static const _storage = FlutterSecureStorage();

  // Keys
  static const String _tokenKey = 'auth_token';
  static const String _roleKey = 'user_role';
  static const String _userIdKey = 'user_id';
  static const String _usernameKey = 'username';
  static const String _emailKey = 'email';

  // Save authentication data
  static Future<void> saveAuthData({
    required String token,
    required String role,
    String? userId,
    String? username,
    String? email,
  }) async {
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _roleKey, value: role);
    if (userId != null) await _storage.write(key: _userIdKey, value: userId);
    if (username != null) await _storage.write(key: _usernameKey, value: username);
    if (email != null) await _storage.write(key: _emailKey, value: email);
  }

  // Get token
  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  // Get role
  static Future<String?> getRole() async {
    return await _storage.read(key: _roleKey);
  }

  // Get user ID
  static Future<String?> getUserId() async {
    return await _storage.read(key: _userIdKey);
  }

  // Get username
  static Future<String?> getUsername() async {
    return await _storage.read(key: _usernameKey);
  }

  // Get email
  static Future<String?> getEmail() async {
    return await _storage.read(key: _emailKey);
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Clear all authentication data (logout)
  static Future<void> clearAuthData() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _roleKey);
    await _storage.delete(key: _userIdKey);
    await _storage.delete(key: _usernameKey);
    await _storage.delete(key: _emailKey);
  }
}
