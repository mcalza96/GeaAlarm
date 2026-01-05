import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'core/di/injection.dart';
import 'features/alarm/presentation/blocs/alarm_cubit.dart';
import 'features/alarm/presentation/blocs/map_cubit.dart';
import 'features/alarm/presentation/blocs/alarm_monitoring_coordinator.dart';
import 'features/alarm/presentation/pages/alarm_list_page.dart';
import 'package:geo_alarm/core/services/i_notification_service.dart';

import 'features/alarm/domain/usecases/boot_alarm_reactivator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependency injection
  configureDependencies();

  // Initialize foreground task BEFORE runApp
  await _initForegroundService();

  // Initialize notification service
  final notificationService = getIt<INotificationService>();
  await notificationService.init();

  // Start monitoring service
  getIt<AlarmMonitoringCoordinator>().init();

  // Reactivate alarms if returning from boot/termination
  await getIt<BootAlarmReactivator>().reactivateActiveAlarms();

  runApp(const GeoAlarmApp());
}

/// Inicializa el servicio de foreground task
Future<void> _initForegroundService() async {
  FlutterForegroundTask.init(
    androidNotificationOptions: AndroidNotificationOptions(
      channelId: 'geofence_service',
      channelName: 'Servicio de Geocercas',
      channelDescription: 'Monitorea tu ubicación para alarmas de destino',
      channelImportance: NotificationChannelImportance.LOW,
      priority: NotificationPriority.LOW,
    ),
    iosNotificationOptions: const IOSNotificationOptions(
      showNotification: true,
      playSound: false,
    ),
    foregroundTaskOptions: ForegroundTaskOptions(
      eventAction: ForegroundTaskEventAction.repeat(5000), // Cada 5 segundos
      autoRunOnBoot: true, // Reiniciar tras reboot
      autoRunOnMyPackageReplaced: true, // Reiniciar tras actualización
      allowWakeLock: true, // Permitir wake lock
      allowWifiLock: false,
    ),
  );
}

class GeoAlarmApp extends StatelessWidget {
  const GeoAlarmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<AlarmCubit>()..loadAlarms()),
        BlocProvider(create: (_) => getIt<MapCubit>()),
      ],
      child: MaterialApp(
        title: 'GeoAlarm',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(centerTitle: true, elevation: 2),
        ),
        home: const AlarmListPage(),
      ),
    );
  }
}
