// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:geo_alarm/core/di/isar_module.dart' as _i31;
import 'package:geo_alarm/core/services/audio_service_impl.dart' as _i5;
import 'package:geo_alarm/core/services/hardware_monitor_service_impl.dart'
    as _i6;
import 'package:geo_alarm/core/services/i_audio_service.dart' as _i4;
import 'package:geo_alarm/core/services/i_location_service.dart' as _i7;
import 'package:geo_alarm/core/services/i_map_service.dart' as _i10;
import 'package:geo_alarm/core/services/i_notification_service.dart' as _i12;
import 'package:geo_alarm/core/services/i_vibration_service.dart' as _i14;
import 'package:geo_alarm/core/services/location_service.dart' as _i8;
import 'package:geo_alarm/core/services/logger_service.dart' as _i9;
import 'package:geo_alarm/core/services/notification_service_impl.dart' as _i13;
import 'package:geo_alarm/core/services/vibration_service_impl.dart' as _i15;
import 'package:geo_alarm/core/services/wake_lock_manager.dart' as _i18;
import 'package:geo_alarm/features/alarm/data/datasources/local/background_geofence_service.dart'
    as _i22;
import 'package:geo_alarm/features/alarm/data/datasources/remote/geocoding_service.dart'
    as _i11;
import 'package:geo_alarm/features/alarm/data/repositories/isar_alarm_repository.dart'
    as _i20;
import 'package:geo_alarm/features/alarm/domain/repositories/i_alarm_repository.dart'
    as _i19;
import 'package:geo_alarm/features/alarm/domain/repositories/i_geofence_service.dart'
    as _i21;
import 'package:geo_alarm/features/alarm/domain/usecases/add_alarm.dart'
    as _i25;
import 'package:geo_alarm/features/alarm/domain/usecases/boot_alarm_reactivator.dart'
    as _i27;
import 'package:geo_alarm/features/alarm/domain/usecases/calculate_proximity.dart'
    as _i3;
import 'package:geo_alarm/features/alarm/domain/usecases/delete_alarm.dart'
    as _i28;
import 'package:geo_alarm/features/alarm/domain/usecases/get_alarms.dart'
    as _i29;
import 'package:geo_alarm/features/alarm/domain/usecases/toggle_alarm_status.dart'
    as _i23;
import 'package:geo_alarm/features/alarm/domain/usecases/update_alarm.dart'
    as _i24;
import 'package:geo_alarm/features/alarm/presentation/blocs/alarm_cubit.dart'
    as _i30;
import 'package:geo_alarm/features/alarm/presentation/blocs/alarm_monitoring_coordinator.dart'
    as _i26;
import 'package:geo_alarm/features/alarm/presentation/blocs/map_cubit.dart'
    as _i17;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;
import 'package:isar/isar.dart' as _i16;

extension GetItInjectableX on _i1.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  Future<_i1.GetIt> init({
    String? environment,
    _i2.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i2.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    final isarModule = _$IsarModule();
    gh.factory<_i3.CalculateProximity>(() => _i3.CalculateProximity());
    gh.lazySingleton<_i4.IAudioService>(() => _i5.AudioServiceImpl());
    gh.lazySingleton<_i6.IHardwareMonitorService>(
        () => _i6.HardwareMonitorService());
    gh.lazySingleton<_i7.ILocationService>(() => _i8.LocationService());
    gh.lazySingleton<_i9.ILoggerService>(() => _i9.LoggerService());
    gh.lazySingleton<_i10.IMapService>(() => _i11.GeocodingService());
    gh.lazySingleton<_i12.INotificationService>(
        () => _i13.NotificationServiceImpl());
    gh.lazySingleton<_i14.IVibrationService>(() => _i15.VibrationServiceImpl());
    await gh.singletonAsync<_i16.Isar>(
      () => isarModule.isar,
      preResolve: true,
    );
    gh.factory<_i17.MapCubit>(() => _i17.MapCubit(
          gh<_i10.IMapService>(),
          gh<_i7.ILocationService>(),
        ));
    gh.lazySingleton<_i18.WakeLockManager>(() => _i18.WakeLockManager());
    gh.lazySingleton<_i19.IAlarmRepository>(
        () => _i20.IsarAlarmRepository(gh<_i16.Isar>()));
    gh.lazySingleton<_i21.IGeofenceService>(
        () => _i22.BackgroundGeofenceService(gh<_i18.WakeLockManager>()));
    gh.factory<_i23.ToggleAlarmStatus>(
        () => _i23.ToggleAlarmStatus(gh<_i19.IAlarmRepository>()));
    gh.factory<_i24.UpdateAlarm>(
        () => _i24.UpdateAlarm(gh<_i19.IAlarmRepository>()));
    gh.factory<_i25.AddAlarm>(() => _i25.AddAlarm(gh<_i19.IAlarmRepository>()));
    gh.lazySingleton<_i26.AlarmMonitoringCoordinator>(
        () => _i26.AlarmMonitoringCoordinator(
              geofenceService: gh<_i21.IGeofenceService>(),
              audioService: gh<_i4.IAudioService>(),
              notificationService: gh<_i12.INotificationService>(),
              vibrationService: gh<_i14.IVibrationService>(),
              alarmRepository: gh<_i19.IAlarmRepository>(),
            ));
    gh.lazySingleton<_i27.BootAlarmReactivator>(() => _i27.BootAlarmReactivator(
          alarmRepository: gh<_i19.IAlarmRepository>(),
          geofenceService: gh<_i21.IGeofenceService>(),
        ));
    gh.factory<_i28.DeleteAlarm>(
        () => _i28.DeleteAlarm(gh<_i19.IAlarmRepository>()));
    gh.factory<_i29.GetAlarms>(
        () => _i29.GetAlarms(gh<_i19.IAlarmRepository>()));
    gh.factory<_i30.AlarmCubit>(() => _i30.AlarmCubit(
          addAlarmUseCase: gh<_i25.AddAlarm>(),
          getAlarmsUseCase: gh<_i29.GetAlarms>(),
          deleteAlarmUseCase: gh<_i28.DeleteAlarm>(),
          toggleAlarmStatusUseCase: gh<_i23.ToggleAlarmStatus>(),
          geofenceService: gh<_i21.IGeofenceService>(),
          updateAlarmUseCase: gh<_i24.UpdateAlarm>(),
        ));
    return this;
  }
}

class _$IsarModule extends _i31.IsarModule {}
