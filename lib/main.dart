import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/injection.dart';
import 'features/alarm/presentation/blocs/alarm_cubit.dart';
import 'features/alarm/presentation/blocs/map_cubit.dart';
import 'features/alarm/presentation/blocs/alarm_monitoring_coordinator.dart';
import 'features/alarm/presentation/pages/alarm_list_page.dart';
import 'package:geo_alarm/core/services/i_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependency injection
  configureDependencies();

  // Initialize notification service
  final notificationService = getIt<INotificationService>();
  await notificationService.init();

  // Start monitoring service
  getIt<AlarmMonitoringCoordinator>().init();

  runApp(const GeoAlarmApp());
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
