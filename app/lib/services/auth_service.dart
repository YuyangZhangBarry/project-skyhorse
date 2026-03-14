import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const _tokenKey = 'auth_token';
  static const _userIdKey = 'user_id';

  final SharedPreferences _prefs;

  AuthService(this._prefs);

  String? get token => _prefs.getString(_tokenKey);
  String? get userId => _prefs.getString(_userIdKey);
  bool get isLoggedIn => token != null;

  Future<void> saveToken(String token) async {
    await _prefs.setString(_tokenKey, token);
    final uid = _extractUserIdFromJwt(token);
    if (uid != null) {
      await _prefs.setString(_userIdKey, uid);
    }
  }

  String? _extractUserIdFromJwt(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final map = jsonDecode(decoded) as Map<String, dynamic>;
      return map['sub'] as String?;
    } catch (_) {
      return null;
    }
  }

  Future<void> clearSession() async {
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_userIdKey);
  }
}
