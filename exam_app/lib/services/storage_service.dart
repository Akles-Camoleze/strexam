import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../models/user.dart';
import '../models/exam_session.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  SharedPreferences? _prefs;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // User storage
  Future<void> saveCurrentUser(User user) async {
    final userJson = json.encode(user.toJson());
    await _prefs?.setString(AppConfig.userKey, userJson);
  }

  User? getCurrentUser() {
    final userJson = _prefs?.getString(AppConfig.userKey);
    if (userJson != null) {
      return User.fromJson(json.decode(userJson));
    }
    return null;
  }

  Future<void> removeCurrentUser() async {
    await _prefs?.remove(AppConfig.userKey);
  }

  // Session storage
  Future<void> saveCurrentSession(ExamSession session) async {
    final sessionJson = json.encode(session.toJson());
    await _prefs?.setString(AppConfig.sessionKey, sessionJson);
  }

  ExamSession? getCurrentSession() {
    final sessionJson = _prefs?.getString(AppConfig.sessionKey);
    if (sessionJson != null) {
      return ExamSession.fromJson(json.decode(sessionJson));
    }
    return null;
  }

  Future<void> removeCurrentSession() async {
    await _prefs?.remove(AppConfig.sessionKey);
  }

  // Generic storage methods
  Future<void> setString(String key, String value) async {
    await _prefs?.setString(key, value);
  }

  String? getString(String key) {
    return _prefs?.getString(key);
  }

  Future<void> setBool(String key, bool value) async {
    await _prefs?.setBool(key, value);
  }

  bool? getBool(String key) {
    return _prefs?.getBool(key);
  }

  Future<void> setInt(String key, int value) async {
    await _prefs?.setInt(key, value);
  }

  int? getInt(String key) {
    return _prefs?.getInt(key);
  }

  Future<void> remove(String key) async {
    await _prefs?.remove(key);
  }

  Future<void> clear() async {
    await _prefs?.clear();
  }
}