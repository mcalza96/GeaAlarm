import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapState extends Equatable {
  final LatLng? selectedLocation;
  final double currentRadius;
  final String? currentAddress;
  final bool isSelecting;
  final bool isLoadingAddress;
  final String? errorMessage;
  final LatLng? userLocation;
  final bool isInitializing;
  final bool isEditing;
  final String? editingAlarmId;
  final bool? editingAlarmIsActive;
  final DateTime? editingAlarmCreatedAt;

  const MapState({
    this.selectedLocation,
    this.currentRadius = 500.0,
    this.currentAddress,
    this.isSelecting = false,
    this.isLoadingAddress = false,
    this.errorMessage,
    this.userLocation,
    this.isInitializing = true,
    this.isEditing = false,
    this.editingAlarmId,
    this.editingAlarmIsActive,
    this.editingAlarmCreatedAt,
  });

  MapState copyWith({
    LatLng? selectedLocation,
    double? currentRadius,
    String? currentAddress,
    bool? isSelecting,
    bool? isLoadingAddress,
    String? errorMessage,
    LatLng? userLocation,
    bool? isInitializing,
    bool? isEditing,
    String? editingAlarmId,
    bool? editingAlarmIsActive,
    DateTime? editingAlarmCreatedAt,
  }) {
    return MapState(
      selectedLocation: selectedLocation ?? this.selectedLocation,
      currentRadius: currentRadius ?? this.currentRadius,
      currentAddress: currentAddress ?? this.currentAddress,
      isSelecting: isSelecting ?? this.isSelecting,
      isLoadingAddress: isLoadingAddress ?? this.isLoadingAddress,
      errorMessage: errorMessage ?? this.errorMessage,
      userLocation: userLocation ?? this.userLocation,
      isInitializing: isInitializing ?? this.isInitializing,
      isEditing: isEditing ?? this.isEditing,
      editingAlarmId: editingAlarmId ?? this.editingAlarmId,
      editingAlarmIsActive: editingAlarmIsActive ?? this.editingAlarmIsActive,
      editingAlarmCreatedAt:
          editingAlarmCreatedAt ?? this.editingAlarmCreatedAt,
    );
  }

  @override
  List<Object?> get props => [
        selectedLocation,
        currentRadius,
        currentAddress,
        isSelecting,
        isLoadingAddress,
        errorMessage,
        userLocation,
        isInitializing,
        isEditing,
        editingAlarmId,
        editingAlarmIsActive,
        editingAlarmCreatedAt,
      ];
}
