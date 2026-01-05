import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../blocs/map_cubit.dart';
import '../blocs/map_state.dart';
import '../blocs/alarm_cubit.dart';
import '../widgets/alarm_setup_sheet.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GoogleMapController? _mapController;
  bool _isSheetOpen = false;
  double? _lastRadius; // Para rastrear cambios en el radio
  LatLng? _lastSelectedLocation; // Para rastrear cambios en la ubicación

  @override
  void initState() {
    super.initState();
    // Obtener ubicación inicial a través del Cubit
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MapCubit>().getUserInitialLocation();
    });
  }

  // Calcula los bounds que contienen completamente el círculo de la geocerca
  LatLngBounds _calculateBoundsFromRadius(
      LatLng center, double radiusInMeters) {
    // Aproximación: 1 grado de latitud ≈ 111km
    // Para longitud, ajustamos por la latitud actual
    const double metersPerDegreeLat = 111000;
    final double metersPerDegreeLng = 111000 * cos(center.latitude * pi / 180);

    final double latOffset = radiusInMeters / metersPerDegreeLat;
    final double lngOffset = radiusInMeters / metersPerDegreeLng;

    return LatLngBounds(
      southwest: LatLng(
        center.latitude - latOffset,
        center.longitude - lngOffset,
      ),
      northeast: LatLng(
        center.latitude + latOffset,
        center.longitude + lngOffset,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MapCubit, MapState>(
      listener: (context, state) {
        if (state.isSelecting && !_isSheetOpen) {
          _isSheetOpen = true;
          showModalBottomSheet(
            context: context,
            isDismissible: false,
            enableDrag: false,
            builder: (_) => BlocProvider.value(
              value: context.read<MapCubit>(),
              child: BlocProvider.value(
                value: context.read<AlarmCubit>(),
                child: const AlarmSetupSheet(),
              ),
            ),
          ).then((_) {
            _isSheetOpen = false;
          });
        }

        // Auto-zoom dinámico basado en el radio de la geocerca
        // Usa LatLngBounds para garantizar que el círculo siempre sea visible
        if (state.selectedLocation != null &&
            state.currentRadius != _lastRadius &&
            _lastRadius != null) {
          // Solo animar si el cambio es significativo (más de 50m)
          if ((state.currentRadius - _lastRadius!).abs() > 50) {
            _lastRadius = state.currentRadius;
            final bounds = _calculateBoundsFromRadius(
              state.selectedLocation!,
              state.currentRadius,
            );
            _mapController?.animateCamera(
              CameraUpdate.newLatLngBounds(bounds, 80),
            );
          } else {
            _lastRadius = state.currentRadius;
          }
        }

        // Centrar cámara cuando cambia la ubicación seleccionada
        if (state.selectedLocation != null &&
            state.selectedLocation != _lastSelectedLocation) {
          _lastSelectedLocation = state.selectedLocation;
          _lastRadius = state.currentRadius;
          final bounds = _calculateBoundsFromRadius(
            state.selectedLocation!,
            state.currentRadius,
          );
          _mapController?.animateCamera(
            CameraUpdate.newLatLngBounds(bounds, 80),
          );
        }

        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.errorMessage!)),
          );
        }
      },
      builder: (context, state) {
        // Mostrar loader mientras se obtiene la ubicación inicial
        if (state.isInitializing || state.userLocation == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Cargando mapa...'),
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: _SearchBar(
              onSearch: (value) =>
                  context.read<MapCubit>().searchAddress(value),
            ),
            backgroundColor: Colors.white,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: Stack(
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: state.userLocation!,
                  zoom: 15,
                ),
                onMapCreated: (controller) => _mapController = controller,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                padding: const EdgeInsets.only(bottom: 100), // Avoid UI overlap
                onLongPress: (location) =>
                    context.read<MapCubit>().selectLocation(location),
                markers: state.selectedLocation != null
                    ? {
                        Marker(
                          markerId: const MarkerId('selected_alarm'),
                          position: state.selectedLocation!,
                        ),
                      }
                    : {},
                circles: state.selectedLocation != null
                    ? {
                        Circle(
                          circleId: const CircleId('alarm_geofence'),
                          center: state.selectedLocation!,
                          radius: state.currentRadius,
                          fillColor: Colors.blue.withValues(alpha: 0.3),
                          strokeColor: Colors.blue,
                          strokeWidth: 2,
                        ),
                      }
                    : {},
              ),
              // Center crosshair/indicator
              if (state.selectedLocation == null)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 40),
                    child: Icon(
                      Icons.location_on,
                      size: 40,
                      color: Colors.redAccent,
                    ),
                  ),
                ),
              if (state.isLoadingAddress)
                const Center(child: CircularProgressIndicator()),

              // Bottom UI hint or button
              Positioned(
                bottom: 24,
                left: 24,
                right: 24,
                child: AnimatedOpacity(
                  opacity: state.selectedLocation == null ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: state.selectedLocation == null
                      ? ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.deepPurple,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () async {
                            final center =
                                await _mapController?.getVisibleRegion();
                            if (center != null) {
                              final latLng = LatLng(
                                (center.northeast.latitude +
                                        center.southwest.latitude) /
                                    2,
                                (center.northeast.longitude +
                                        center.southwest.longitude) /
                                    2,
                              );
                              if (context.mounted) {
                                context.read<MapCubit>().selectLocation(latLng);
                              }
                            }
                          },
                          icon: const Icon(Icons.add_alert),
                          label: const Text('Configurar Alarma en este punto'),
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SearchBar extends StatelessWidget {
  final Function(String) onSearch;

  const _SearchBar({required this.onSearch});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        decoration: const InputDecoration(
          hintText: 'Buscar destino...',
          prefixIcon: Icon(Icons.search, size: 20),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 10),
        ),
        onSubmitted: onSearch,
      ),
    );
  }
}
