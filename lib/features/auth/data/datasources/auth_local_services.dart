import 'package:rx_shared_preferences/rx_shared_preferences.dart';

class AuthLocalServices {
  static const _keyToken = 'session_token';
  static const _keyRememberMe = 'remember_me';
  final RxSharedPreferences _prefs;

  AuthLocalServices(this._prefs);

  Future<void> saveToken(String token) => _prefs.setString(_keyToken, token);

  Future<String?> getToken() async {
    return await _prefs.getString(_keyToken);
  }

  Stream<String?> tokenStream() => _prefs.getStringStream(_keyToken);

  Future<void> setRememberMe(bool value) =>
      _prefs.setBool(_keyRememberMe, value);

  Future<bool> getRememberMe() async {
    final bool? value = await _prefs.getBool(_keyRememberMe);
    return value ?? false;
  }

  Stream<bool> rememberMeStream() =>
      _prefs.getBoolStream(_keyRememberMe).map((v) => v ?? false);

  Future<void> clearSession() async {
    await _prefs.remove(_keyToken);
    await _prefs.remove(_keyRememberMe);
  }
}
