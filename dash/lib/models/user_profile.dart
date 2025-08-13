import 'package:hive/hive.dart';

@HiveType(typeId: 1)
class UserProfile {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  int avatarIndex;

  @HiveField(3)
  int currentTable;

  @HiveField(4)
  int streakDays;

  @HiveField(5)
  int stars;

  @HiveField(6)
  int coins;

  UserProfile({
    required this.id,
    required this.name,
    this.avatarIndex = 0,
    this.currentTable = 2,
    this.streakDays = 0,
    this.stars = 0,
    this.coins = 0,
  });

  UserProfile copyWith({
    String? id,
    String? name,
    int? avatarIndex,
    int? currentTable,
    int? streakDays,
    int? stars,
    int? coins,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarIndex: avatarIndex ?? this.avatarIndex,
      currentTable: currentTable ?? this.currentTable,
      streakDays: streakDays ?? this.streakDays,
      stars: stars ?? this.stars,
      coins: coins ?? this.coins,
    );
  }
}

class UserProfileAdapter extends TypeAdapter<UserProfile> {
  @override
  final int typeId = 1;

  @override
  UserProfile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return UserProfile(
      id: fields[0] as String,
      name: fields[1] as String,
      avatarIndex: (fields[2] as int?) ?? 0,
      currentTable: (fields[3] as int?) ?? 2,
      streakDays: (fields[4] as int?) ?? 0,
      stars: (fields[5] as int?) ?? 0,
      coins: (fields[6] as int?) ?? 0,
    );
  }

  @override
  void write(BinaryWriter writer, UserProfile obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.avatarIndex)
      ..writeByte(3)
      ..write(obj.currentTable)
      ..writeByte(4)
      ..write(obj.streakDays)
      ..writeByte(5)
      ..write(obj.stars)
      ..writeByte(6)
      ..write(obj.coins);
  }
}