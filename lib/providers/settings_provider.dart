import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider extends ChangeNotifier {
  late SharedPreferences _prefs;
  
  // Settings keys
  static const String _themeKey = 'theme_mode';
  static const String _notificationsEnabledKey = 'notifications_enabled';
  static const String _remindersAtKey = 'reminders_at';
  static const String _quietHoursStartKey = 'quiet_hours_start';
  static const String _quietHoursEndKey = 'quiet_hours_end';
  static const String _soundEnabledKey = 'sound_enabled';
  static const String _vibrationEnabledKey = 'vibration_enabled';
  static const String _lowStockAlertKey = 'low_stock_alert';
  static const String _userNameKey = 'user_name';

  // Default values
  bool _notificationsEnabled = true;
  String _remindersAt = '09:00';
  String _quietHoursStart = '22:00';
  String _quietHoursEnd = '08:00';
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _lowStockAlert = true;
  String _userName = 'User';
  ThemeMode _themeMode = ThemeMode.system;

  // ── Getters ────────────────────────────────────────────
  bool get notificationsEnabled => _notificationsEnabled;
  String get remindersAt => _remindersAt;
  String get quietHoursStart => _quietHoursStart;
  String get quietHoursEnd => _quietHoursEnd;
  bool get soundEnabled => _soundEnabled;
  bool get vibrationEnabled => _vibrationEnabled;
  bool get lowStockAlert => _lowStockAlert;
  String get userName => _userName;
  ThemeMode get themeMode => _themeMode;

  // ── Initialize ────────────────────────────────────────────
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    
    _notificationsEnabled = _prefs.getBool(_notificationsEnabledKey) ?? true;
    _remindersAt = _prefs.getString(_remindersAtKey) ?? '09:00';
    _quietHoursStart = _prefs.getString(_quietHoursStartKey) ?? '22:00';
    _quietHoursEnd = _prefs.getString(_quietHoursEndKey) ?? '08:00';
    _soundEnabled = _prefs.getBool(_soundEnabledKey) ?? true;
    _vibrationEnabled = _prefs.getBool(_vibrationEnabledKey) ?? true;
    _lowStockAlert = _prefs.getBool(_lowStockAlertKey) ?? true;
    _userName = _prefs.getString(_userNameKey) ?? 'User';
    
    final themeModeIndex = _prefs.getInt(_themeKey) ?? 0;
    _themeMode = ThemeMode.values[themeModeIndex];
    
    notifyListeners();
  }

  // ── Actions ────────────────────────────────────────────

  Future<void> setNotificationsEnabled(bool value) async {
    _notificationsEnabled = value;
    await _prefs.setBool(_notificationsEnabledKey, value);
    notifyListeners();
  }

  Future<void> setRemindersAt(String time) async {
    _remindersAt = time;
    await _prefs.setString(_remindersAtKey, time);
    notifyListeners();
  }

  Future<void> setQuietHoursStart(String time) async {
    _quietHoursStart = time;
    await _prefs.setString(_quietHoursStartKey, time);
    notifyListeners();
  }

  Future<void> setQuietHoursEnd(String time) async {
    _quietHoursEnd = time;
    await _prefs.setString(_quietHoursEndKey, time);
    notifyListeners();
  }

  Future<void> setSoundEnabled(bool value) async {
    _soundEnabled = value;
    await _prefs.setBool(_soundEnabledKey, value);
    notifyListeners();
  }

  Future<void> setVibrationEnabled(bool value) async {
    _vibrationEnabled = value;
    await _prefs.setBool(_vibrationEnabledKey, value);
    notifyListeners();
  }

  Future<void> setLowStockAlert(bool value) async {
    _lowStockAlert = value;
    await _prefs.setBool(_lowStockAlertKey, value);
    notifyListeners();
  }

  Future<void> setUserName(String name) async {
    _userName = name;
    await _prefs.setString(_userNameKey, name);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _prefs.setInt(_themeKey, mode.index);
    notifyListeners();
  }

  Future<void> clearAllData() async {
    await _prefs.clear();
    // Reset to defaults
    _notificationsEnabled = true;
    _remindersAt = '09:00';
    _quietHoursStart = '22:00';
    _quietHoursEnd = '08:00';
    _soundEnabled = true;
    _vibrationEnabled = true;
    _lowStockAlert = true;
    _userName = 'User';
    _themeMode = ThemeMode.system;
    notifyListeners();
  }
}
