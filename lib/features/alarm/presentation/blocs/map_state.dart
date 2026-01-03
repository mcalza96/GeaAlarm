import 'package:equatable/equatable.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapState extends Equatable {
  final LatLng? selectedLocation;
  final double currentRadius;
  final String? currentAddress;
  final bool isSelecting;
  final bool isLoadingAddress;
  final String? errorMessage;

  const MapState({
    this.selectedLocation,
    this.currentRadius = 500.0,
    this.currentAddress,
    this.isSelecting = false,
    this.isLoadingAddress = false,
    this.errorMessage,
  });

  MapState copyWith({
    LatLng? selectedLocation,
    double? currentRadius,
    String? currentAddress,
    bool? isSelecting,
    bool? isLoadingAddress,
    String? errorMessage,
  }) {
    return MapState(
      selectedLocation: selectedLocation ?? this.selectedLocation,
      currentRadius: currentRadius ?? this.currentRadius,
      currentAddress: currentAddress ?? this.currentAddress,
      isSelecting: isSelecting ?? this.isSelecting,
      isLoadingAddress: isLoadingAddress ?? this.isLoadingAddress,
      errorMessage: errorMessage ?? this.errorMessage,
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
      ];
}
