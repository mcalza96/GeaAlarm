import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/services/i_map_service.dart';
import 'map_state.dart';

@injectable
class MapCubit extends Cubit<MapState> {
  final IMapService mapService;

  MapCubit(this.mapService) : super(const MapState());

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

  void updateRadius(double radius) {
    emit(state.copyWith(currentRadius: radius));
  }

  void resetSelection() {
    emit(const MapState());
  }
}
