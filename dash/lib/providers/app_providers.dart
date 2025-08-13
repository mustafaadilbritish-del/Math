import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../models/user_profile.dart';
import '../models/progress_models.dart';
import '../services/storage_service.dart';

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

final appInitializationProvider = FutureProvider<void>((ref) async {
  final storage = ref.read(storageServiceProvider);
  await storage.initialize();
});

final profilesProvider = StateNotifierProvider<ProfilesController, List<UserProfile>>((ref) {
  final storage = ref.read(storageServiceProvider);
  return ProfilesController(storage);
});

class ProfilesController extends StateNotifier<List<UserProfile>> {
  final StorageService storage;
  ProfilesController(this.storage) : super([]) {
    _load();
  }

  Future<void> _load() async {
    state = await storage.getProfiles();
  }

  Future<void> addProfile(String name) async {
    final profile = UserProfile(id: const Uuid().v4(), name: name);
    await storage.saveProfile(profile);
    await _load();
  }

  Future<void> deleteProfile(String id) async {
    await storage.deleteProfile(id);
    await _load();
  }
}

final activeProfileIdProvider = StateProvider<String?>((ref) {
  final storage = ref.read(storageServiceProvider);
  return storage.getActiveProfileId();
});

final progressMapProvider = StateNotifierProvider<ProgressController, Map<String, LessonProgress>>((ref) {
  final storage = ref.read(storageServiceProvider);
  return ProgressController(storage);
});

class ProgressController extends StateNotifier<Map<String, LessonProgress>> {
  final StorageService storage;
  ProgressController(this.storage) : super({}) {
    state = storage.loadProgressMap();
  }

  String _key(int table, bool isDivision) => '${isDivision ? 'div' : 'mul'}_$table';

  LessonProgress getProgress(int table, bool isDivision) {
    return state[_key(table, isDivision)] ?? LessonProgress(table: table, isDivision: isDivision);
  }

  Future<void> updateProgress(LessonProgress progress) async {
    final newMap = Map<String, LessonProgress>.from(state);
    newMap[_key(progress.table, progress.isDivision)] = progress;
    state = newMap;
    await storage.saveProgressMap(state);
  }
}

final appSettingsProvider = StateProvider<AppSettings>((ref) {
  return const AppSettings();
});

class AppSettings {
  final bool soundEnabled;
  final bool animationsEnabled;
  const AppSettings({this.soundEnabled = true, this.animationsEnabled = true});

  AppSettings copyWith({bool? soundEnabled, bool? animationsEnabled}) => AppSettings(
        soundEnabled: soundEnabled ?? this.soundEnabled,
        animationsEnabled: animationsEnabled ?? this.animationsEnabled,
      );
}