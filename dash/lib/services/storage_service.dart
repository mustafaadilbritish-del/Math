import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_profile.dart';
import '../models/progress_models.dart';

class StorageService {
  static const String profilesBoxName = 'profiles';
  static const String progressKey = 'progress_json';
  static const String activeProfileIdKey = 'active_profile_id';

  late final Box<UserProfile> _profilesBox;
  late final SharedPreferences _prefs;

  Future<void> initialize() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(UserProfileAdapter());
    }
    _profilesBox = await Hive.openBox<UserProfile>(profilesBoxName);
    _prefs = await SharedPreferences.getInstance();
  }

  Future<List<UserProfile>> getProfiles() async {
    return _profilesBox.values.toList();
  }

  Future<void> saveProfile(UserProfile profile) async {
    await _profilesBox.put(profile.id, profile);
  }

  Future<void> deleteProfile(String id) async {
    await _profilesBox.delete(id);
  }

  String? getActiveProfileId() {
    return _prefs.getString(activeProfileIdKey);
  }

  Future<void> setActiveProfileId(String id) async {
    await _prefs.setString(activeProfileIdKey, id);
  }

  Map<String, LessonProgress> loadProgressMap() {
    final raw = _prefs.getString(progressKey);
    if (raw == null || raw.isEmpty) return {};
    final Map<String, dynamic> decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map((key, value) => MapEntry(
          key,
          LessonProgress.fromJson(value as Map<String, dynamic>),
        ));
  }

  Future<void> saveProgressMap(Map<String, LessonProgress> map) async {
    final json = map.map((key, value) => MapEntry(key, value.toJson()));
    await _prefs.setString(progressKey, jsonEncode(json));
  }
}