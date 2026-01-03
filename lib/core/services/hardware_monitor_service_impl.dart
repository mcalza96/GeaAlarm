import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';
import 'dart:async';

abstract class IHardwareMonitorService {
  Stream<bool> get isGpsEnabled;
  Future<bool> checkGpsStatus();
}

@LazySingleton(as: IHardwareMonitorService)
class HardwareMonitorService implements IHardwareMonitorService {
  @override
  Stream<bool> get isGpsEnabled => Geolocator.getServiceStatusStream()
      .map((status) => status == ServiceStatus.enabled);

  @override
  Future<bool> checkGpsStatus() async {
    return await Geolocator.isLocationServiceEnabled();
  }
}
