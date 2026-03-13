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
  }

  Future<void> saveUserId(String userId) async {
    await _prefs.setString(_userIdKey, userId);
  }

  Future<void> clearSession() async {
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_userIdKey);
  }
}
