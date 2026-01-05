import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/services/i_map_service.dart';
import '../../../../core/services/i_location_service.dart';
import '../../domain/entities/alarm.dart';
import 'map_state.dart';

@injectable
class MapCubit extends Cubit<MapState> {
  final IMapService mapService;
  final ILocationService locationService;

  MapCubit(this.mapService, this.locationService) : super(const MapState());

  Future<void> getUserInitialLocation() async {
    emit(state.copyWith(isInitializing: true));

    final result = await locationService.getCurrentPosition();

    result.fold(
      (failure) => emit(state.copyWith(
        isInitializing: false,
        errorMessage: failure.message,
      )),
      (position) {
        final userLocation = LatLng(position.latitude, position.longitude);
        emit(state.copyWith(
          userLocation: userLocation,
          isInitializing: false,
        ));
      },
    );
  }

  void selectLocation(LatLng location) async {
    emit(state.copyWith(
      selectedLocation: location,
      isSelecting: true,
      isLoadingAddress: true,
      errorMessage: null,
    ));

    final result = await mapService.getAddressFromCoords(
      location.latitude,
      location.longitude,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        isLoadingAddress: false,
        errorMessage: failure.message,
      )),
      (address) => emit(state.copyWith(
        isLoadingAddress: false,
        currentAddress: address,
      )),
    );
  }

  void searchAddress(String address) async {
    emit(state.copyWith(isLoadingAddress: true, errorMessage: null));

    final result = await mapService.getCoordsFromAddress(address);

    result.fold(
      (failure) => emit(state.copyWith(
        isLoadingAddress: false,
        errorMessage: failure.message,
      )),
      (coords) {
        final location = LatLng(coords[0], coords[1]);
        emit(state.copyWith(
          selectedLocation: location,
          isLoadingAddress: false,
          currentAddress: address,
        ));
      },
    );
  }

  void updateRadius(double radius) {
    emit(state.copyWith(currentRadius: radius));
  }

  void resetSelection() {
    // Resetear también el ID de edición
    emit(state.copyWith(
      selectedLocation: null,
      currentRadius: 500.0,
      currentAddress: null,
      isSelecting: false,
      isLoadingAddress: false,
      errorMessage: null,
      editingAlarmId:
          null, // Reset explícito (aunque copyWith con null no lo cambiaría si no pasamos nada, aquí queremos borrarlo)
    ));
    // O mejor, emitir un estado limpio conservando userLocation e initialization status
    // Pero MapState() constructor tiene defaults.
    // emit(const MapState()); // Esto borraría userLocation, lo cual NO queremos si ya se inicializó.

    // Mejor opción:
    emit(MapState(
      userLocation: state.userLocation,
      isInitializing: state.isInitializing,
      isEditing: false,
      // Resto defaults
    ));
  }

  Future<void> loadAlarmToEdit(Alarm alarm) async {
    final location = LatLng(alarm.latitude, alarm.longitude);

    // Emitir estado inicial con loading de dirección
    emit(state.copyWith(
      selectedLocation: location,
      currentRadius: alarm.radius,
      currentAddress: alarm.label, // Usar label como fallback inicial
      isSelecting: true,
      isEditing: true,
      isLoadingAddress: true, // Indicar que estamos cargando la dirección
      editingAlarmId: alarm.id,
      editingAlarmIsActive: alarm.isActive,
      editingAlarmCreatedAt: alarm.createdAt,
    ));

    // Obtener dirección actualizada mediante geocodificación inversa
    final result = await mapService.getAddressFromCoords(
      alarm.latitude,
      alarm.longitude,
    );

    result.fold(
      (failure) {
        // En caso de error, mantener el label original y quitar loading
        emit(state.copyWith(
          isLoadingAddress: false,
          currentAddress: alarm.label,
        ));
      },
      (address) {
        // Actualizar con la dirección obtenida
        emit(state.copyWith(
          isLoadingAddress: false,
          currentAddress: address,
        ));
      },
    );
  }

  void selectAsDestination(LatLng location) async {
    selectLocation(location);
  }
}
