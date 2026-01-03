import 'package:isar/isar.dart';
import '../../domain/entities/alarm.dart';

part 'alarm_model.g.dart';

@Collection()
class AlarmModel extends Alarm {
  Id get isarId => fastHash(id);

  const AlarmModel({
    required super.id,
    required super.latitude,
    required super.longitude,
    required super.radius,
    required super.label,
    super.isActive = true,
    required super.createdAt,
  });

  factory AlarmModel.fromEntity(Alarm alarm) {
    return AlarmModel(
      id: alarm.id,
      latitude: alarm.latitude,
      longitude: alarm.longitude,
      radius: alarm.radius,
      label: alarm.label,
      isActive: alarm.isActive,
      createdAt: alarm.createdAt,
    );
  }

  factory AlarmModel.fromJson(Map<String, dynamic> json) {
    return AlarmModel(
      id: json['id'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      radius: (json['radius'] as num).toDouble(),
      label: json['label'] as String,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius,
      'label': label,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

/// FNV-1a 64bit hash algorithm optimized for Dart Strings
int fastHash(String string) {
  var hash = 0xcbf29ce484222325;
  var i = 0;
  while (i < string.length) {
    final codeUnit = string.codeUnitAt(i++);
    hash ^= codeUnit >> 8;
    hash *= 0x100000001b3;
    hash ^= codeUnit & 0xFF;
    hash *= 0x100000001b3;
  }
  return hash;
}
