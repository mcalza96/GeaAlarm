import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../blocs/map_cubit.dart';
import '../blocs/map_state.dart';
import '../widgets/alarm_setup_sheet.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  GoogleMapController? _mapController;
  LatLng? _currentPosition;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final status = await Permission.locationWhenInUse.request();
    if (status.isGranted) {
      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_currentPosition!, 15),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MapCubit, MapState>(
      listener: (context, state) {
        if (state.isSelecting) {
          showModalBottomSheet(
            context: context,
            isDismissible: false,
            enableDrag: false,
            builder: (_) => BlocProvider.value(
              value: context.read<MapCubit>(),
              child: const AlarmSetupSheet(),
            ),
          ).then((_) {
            // Logic handled by buttons in sheet or if needed reset on dismiss
          });
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: Stack(
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _currentPosition ?? const LatLng(0, 0),
                  zoom: 2,
                ),
                onMapCreated: (controller) => _mapController = controller,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
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
                          fillColor: Colors.blue.withOpacity(0.3),
                          strokeColor: Colors.blue,
                          strokeWidth: 2,
                        ),
                      }
                    : {},
              ),
              if (state.isLoadingAddress)
                const Center(child: CircularProgressIndicator()),
            ],
          ),
        );
      },
    );
  }
}
