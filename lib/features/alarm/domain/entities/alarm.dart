class Alarm {
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
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Alarm &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          latitude == other.latitude &&
          longitude == other.longitude &&
          radius == other.radius &&
          label == other.label &&
          isActive == other.isActive &&
          createdAt == other.createdAt;

  @override
  int get hashCode =>
      id.hashCode ^
      latitude.hashCode ^
      longitude.hashCode ^
      radius.hashCode ^
      label.hashCode ^
      isActive.hashCode ^
      createdAt.hashCode;
}
