import 'package:equatable/equatable.dart';

class Alarm extends Equatable {
  final String id;
  final double latitude;
  final double longitude;
  final double radius; // in meters
  final String label;
  final bool isActive;
  final DateTime createdAt;

  const Alarm({
    required this.id,
    required this.latitude,
    required this.longitude,
    required this.radius,
    required this.label,
    this.isActive = true,
    required this.createdAt,
  });

  Alarm copyWith({
    String? id,
    double? latitude,
    double? longitude,
    double? radius,
    String? label,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return Alarm(
      id: id ?? this.id,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radius: radius ?? this.radius,
      label: label ?? this.label,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        latitude,
        longitude,
        radius,
        label,
        isActive,
        createdAt,
      ];
}
