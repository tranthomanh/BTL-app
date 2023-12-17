import 'dart:convert';

import 'package:ccvc_mobile/utils/constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrefsService {
  static const _PREF_USERID = 'pref_user_id';
  static const _PREF_TOKEN = 'pref_token';
  static const _PREF_REFRESH_TOKEN = 'pref_token';
  static const _PREF_PASSWORD_PRESENT = 'pref_password_present';
  static const _PREF_DATA_USER = 'pref_data_user';
  static const _PREF_APP_THEME = 'pref_app_theme';
  static const _PREF_IS_CREATE_INFO = 'pref_is_create_info';

  static SharedPreferences? _prefsInstance;

  static Future<SharedPreferences> get _instance async =>
      _prefsInstance ??= await SharedPreferences.getInstance();

  // call this method form iniState() function of mainApp().
  static Future<SharedPreferences> init() async {
    _prefsInstance = await _instance;
    return _prefsInstance!;
  }

  static bool getIsCreateInfo() {
    return _prefsInstance?.getBool(_PREF_IS_CREATE_INFO) ?? false;
  }

  static Future<Future<bool>> saveIsCreateInfo(bool isInfo) async {
    final prefs = await _instance;
    return prefs.setBool(_PREF_IS_CREATE_INFO, isInfo);
  }

  static Future<void> removeIsInfo() async {
    final prefs = await _instance;
    if (prefs.containsKey(_PREF_IS_CREATE_INFO)) {
      await prefs.remove(_PREF_IS_CREATE_INFO);
    }
  }

  static String getToken() {
    return _prefsInstance?.getString(_PREF_TOKEN) ?? '';
  }

  static Future<bool> saveToken(String token) async {
    final prefs = await _instance;
    return prefs.setString(_PREF_TOKEN, token);
  }

  static Future<bool> saveRefreshToken(String token) async {
    final prefs = await _instance;
    return prefs.setString(_PREF_REFRESH_TOKEN, token);
  }

  static Future<bool> savePasswordPresent(String passwordPresent) async {
    final prefs = await _instance;
    return prefs.setString(_PREF_PASSWORD_PRESENT, passwordPresent);
  }

  static Future<bool> saveDataUser(String data) async {
    final prefs = await _instance;
    return prefs.setString(_PREF_DATA_USER, data);
  }

  static Future<bool> saveUserId(String code) async {
    final prefs = await _instance;
    return prefs.setString(_PREF_USERID, code);
  }

  static String getUserId() {
    return _prefsInstance?.getString(_PREF_USERID) ?? '';
  }

  static String getPasswordPresent() {
    return _prefsInstance?.getString(_PREF_PASSWORD_PRESENT) ?? '';
  }

  static Future<void> updatePasswordPresent(String password) async {
    await removePasswordPresent();
    await savePasswordPresent(password);
  }

  static Future<void> removeUserId() async {
    final prefs = await _instance;
    if (prefs.containsKey(_PREF_USERID)) {
      await prefs.remove(_PREF_USERID);
    }
  }

  static Future<void> removeTokken() async {
    final prefs = await _instance;
    if (prefs.containsKey(_PREF_TOKEN)) {
      await prefs.remove(_PREF_TOKEN);
    }
  }

  static Future<void> removePasswordPresent() async {
    final prefs = await _instance;
    if (prefs.containsKey(_PREF_PASSWORD_PRESENT)) {
      await prefs.remove(_PREF_PASSWORD_PRESENT);
    }
  }

  Future<void> clearData() async {
    await _prefsInstance?.clear();
    return;
  }
}
