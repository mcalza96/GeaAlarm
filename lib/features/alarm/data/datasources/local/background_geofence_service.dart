import 'dart:async';
import 'package:easy_geofencing/easy_geofencing.dart';
import 'package:easy_geofencing/enums/geofence_status.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/alarm.dart';
import '../../domain/repositories/i_geofence_service.dart';

@LazySingleton(as: IGeofenceService)
class BackgroundGeofenceService implements IGeofenceService {
  final _controller = StreamController<String>.broadcast();

  @override
  Stream<String> get onGeofenceTriggered => _controller.stream;

  @override
  Future<void> registerGeofence(Alarm alarm) async {
    EasyGeofencing.startGeofencing(
      latitude: alarm.latitude.toString(),
      longitude: alarm.longitude.toString(),
      radius: alarm.radius.toString(),
      eventPeriodInSeconds: 5,
    );

    EasyGeofencing.getGeofenceStream()?.listen((GeofenceStatus status) {
      if (status == GeofenceStatus.ENTER) {
        _controller.add(alarm.id);
      }
    });
  }

  @override
  Future<void> removeGeofence(String id) async {
    EasyGeofencing.stopGeofencing();
  }
}
