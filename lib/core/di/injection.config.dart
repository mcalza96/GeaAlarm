// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:geo_alarm/core/di/isar_module.dart' as _i25;
import 'package:geo_alarm/core/services/audio_service_impl.dart' as _i5;
import 'package:geo_alarm/core/services/hardware_monitor_service_impl.dart'
    as _i8;
import 'package:geo_alarm/core/services/i_audio_service.dart' as _i4;
import 'package:geo_alarm/core/services/i_map_service.dart' as _i10;
import 'package:geo_alarm/core/services/i_notification_service.dart' as _i12;
import 'package:geo_alarm/core/services/logger_service.dart' as _i9;
import 'package:geo_alarm/core/services/notification_service_impl.dart' as _i13;
import 'package:geo_alarm/features/alarm/data/datasources/local/background_geofence_service.dart'
    as _i7;
import 'package:geo_alarm/features/alarm/data/datasources/remote/geocoding_service.dart'
    as _i11;
import 'package:geo_alarm/features/alarm/data/repositories/isar_alarm_repository.dart'
    as _i17;
import 'package:geo_alarm/features/alarm/domain/repositories/i_alarm_repository.dart'
    as _i16;
import 'package:geo_alarm/features/alarm/domain/repositories/i_geofence_service.dart'
    as _i6;
import 'package:geo_alarm/features/alarm/domain/usecases/add_alarm.dart'
    as _i19;
import 'package:geo_alarm/features/alarm/domain/usecases/boot_alarm_reactivator.dart'
    as _i21;
import 'package:geo_alarm/features/alarm/domain/usecases/calculate_proximity.dart'
    as _i3;
import 'package:geo_alarm/features/alarm/domain/usecases/delete_alarm.dart'
    as _i22;
import 'package:geo_alarm/features/alarm/domain/usecases/get_alarms.dart'
    as _i23;
import 'package:geo_alarm/features/alarm/domain/usecases/toggle_alarm_status.dart'
    as _i18;
import 'package:geo_alarm/features/alarm/presentation/blocs/alarm_cubit.dart'
    as _i24;
import 'package:geo_alarm/features/alarm/presentation/blocs/alarm_monitoring_coordinator.dart'
    as _i20;
import 'package:geo_alarm/features/alarm/presentation/blocs/map_cubit.dart'
    as _i15;
import 'package:get_it/get_it.dart' as _i1;
import 'package:injectable/injectable.dart' as _i2;
import 'package:isar/isar.dart' as _i14;

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
    gh.lazySingleton<_i6.IGeofenceService>(
        () => _i7.BackgroundGeofenceService());
    gh.lazySingleton<_i8.IHardwareMonitorService>(
        () => _i8.HardwareMonitorService());
    gh.lazySingleton<_i9.ILoggerService>(() => _i9.LoggerService());
    gh.lazySingleton<_i10.IMapService>(() => _i11.GeocodingService());
    gh.lazySingleton<_i12.INotificationService>(
        () => _i13.NotificationServiceImpl());
    await gh.singletonAsync<_i14.Isar>(
      () => isarModule.isar,
      preResolve: true,
    );
    gh.factory<_i15.MapCubit>(() => _i15.MapCubit(gh<_i10.IMapService>()));
    gh.lazySingleton<_i16.IAlarmRepository>(
        () => _i17.IsarAlarmRepository(gh<_i14.Isar>()));
    gh.factory<_i18.ToggleAlarmStatus>(
        () => _i18.ToggleAlarmStatus(gh<_i16.IAlarmRepository>()));
    gh.factory<_i19.AddAlarm>(() => _i19.AddAlarm(gh<_i16.IAlarmRepository>()));
    gh.lazySingleton<_i20.AlarmMonitoringCoordinator>(
        () => _i20.AlarmMonitoringCoordinator(
              geofenceService: gh<_i6.IGeofenceService>(),
              audioService: gh<_i4.IAudioService>(),
              notificationService: gh<_i12.INotificationService>(),
              alarmRepository: gh<_i16.IAlarmRepository>(),
            ));
    gh.lazySingleton<_i21.BootAlarmReactivator>(() => _i21.BootAlarmReactivator(
          alarmRepository: gh<_i16.IAlarmRepository>(),
          geofenceService: gh<_i6.IGeofenceService>(),
        ));
    gh.factory<_i22.DeleteAlarm>(
        () => _i22.DeleteAlarm(gh<_i16.IAlarmRepository>()));
    gh.factory<_i23.GetAlarms>(
        () => _i23.GetAlarms(gh<_i16.IAlarmRepository>()));
    gh.factory<_i24.AlarmCubit>(() => _i24.AlarmCubit(
          addAlarmUseCase: gh<_i19.AddAlarm>(),
          getAlarmsUseCase: gh<_i23.GetAlarms>(),
          deleteAlarmUseCase: gh<_i22.DeleteAlarm>(),
          toggleAlarmStatusUseCase: gh<_i18.ToggleAlarmStatus>(),
          geofenceService: gh<_i6.IGeofenceService>(),
        ));
    return this;
  }
}

class _$IsarModule extends _i25.IsarModule {}
