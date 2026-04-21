import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_profile.dart';

class ProfileProvider extends ChangeNotifier {
  late SharedPreferences _prefs;
  late UserProfile _profile;
  
  static const String _profileKey = 'user_profile';

  // ── Getters ────────────────────────────────────────────
  UserProfile get profile => _profile;

  bool get isProfileComplete =>
      _profile.email.isNotEmpty &&
      _profile.phone.isNotEmpty &&
      _profile.dateOfBirth.isNotEmpty &&
      _profile.emergencyContact.isNotEmpty &&
      _profile.emergencyPhone.isNotEmpty;

  // ── Initialize ────────────────────────────────────────────
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    
    final profileJson = _prefs.getString(_profileKey);
    if (profileJson != null) {
      _profile = UserProfile.fromJson(jsonDecode(profileJson));
    } else {
      // Default profile
      _profile = UserProfile(
        id: 1,
        name: 'User',
        email: '',
        phone: '',
        dateOfBirth: '',
        bloodType: 'O+',
        allergies: 'None',
        emergencyContact: '',
        emergencyPhone: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
    
    notifyListeners();
  }

  // ── Actions ────────────────────────────────────────────

  Future<void> updateProfile(UserProfile newProfile) async {
    _profile = newProfile.copyWith(updatedAt: DateTime.now());
    await _prefs.setString(_profileKey, jsonEncode(_profile.toJson()));
    notifyListeners();
  }

  Future<void> updateName(String name) async {
    _profile = _profile.copyWith(
      name: name,
      updatedAt: DateTime.now(),
    );
    await _prefs.setString(_profileKey, jsonEncode(_profile.toJson()));
    notifyListeners();
  }

  Future<void> updateEmail(String email) async {
    _profile = _profile.copyWith(
      email: email,
      updatedAt: DateTime.now(),
    );
    await _prefs.setString(_profileKey, jsonEncode(_profile.toJson()));
    notifyListeners();
  }

  Future<void> updatePhone(String phone) async {
    _profile = _profile.copyWith(
      phone: phone,
      updatedAt: DateTime.now(),
    );
    await _prefs.setString(_profileKey, jsonEncode(_profile.toJson()));
    notifyListeners();
  }

  Future<void> updateDateOfBirth(String date) async {
    _profile = _profile.copyWith(
      dateOfBirth: date,
      updatedAt: DateTime.now(),
    );
    await _prefs.setString(_profileKey, jsonEncode(_profile.toJson()));
    notifyListeners();
  }

  Future<void> updateBloodType(String bloodType) async {
    _profile = _profile.copyWith(
      bloodType: bloodType,
      updatedAt: DateTime.now(),
    );
    await _prefs.setString(_profileKey, jsonEncode(_profile.toJson()));
    notifyListeners();
  }

  Future<void> updateAllergies(String allergies) async {
    _profile = _profile.copyWith(
      allergies: allergies,
      updatedAt: DateTime.now(),
    );
    await _prefs.setString(_profileKey, jsonEncode(_profile.toJson()));
    notifyListeners();
  }

  Future<void> updateEmergencyContact(String name, String phone) async {
    _profile = _profile.copyWith(
      emergencyContact: name,
      emergencyPhone: phone,
      updatedAt: DateTime.now(),
    );
    await _prefs.setString(_profileKey, jsonEncode(_profile.toJson()));
    notifyListeners();
  }
}
