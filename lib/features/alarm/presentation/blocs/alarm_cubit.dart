import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/alarm.dart';
import '../../domain/usecases/add_alarm.dart';
import '../../domain/usecases/delete_alarm.dart';
import '../../domain/usecases/get_alarms.dart';
import '../../domain/usecases/toggle_alarm_status.dart';
import '../../domain/repositories/i_geofence_service.dart';
import '../../../../core/usecases/usecase.dart';
import 'alarm_state.dart';

@injectable
class AlarmCubit extends Cubit<AlarmState> {
  final AddAlarm addAlarmUseCase;
  final GetAlarms getAlarmsUseCase;
  final DeleteAlarm deleteAlarmUseCase;
  final ToggleAlarmStatus toggleAlarmStatusUseCase;
  final IGeofenceService geofenceService;

  AlarmCubit({
    required this.addAlarmUseCase,
    required this.getAlarmsUseCase,
    required this.deleteAlarmUseCase,
    required this.toggleAlarmStatusUseCase,
    required this.geofenceService,
  }) : super(const AlarmInitial());

  Future<void> loadAlarms() async {
    emit(const AlarmLoading());
    final result = await getAlarmsUseCase(NoParams());
    result.fold(
      (failure) => emit(AlarmError(failure.message)),
      (alarms) => emit(AlarmsLoaded(alarms)),
    );
  }

  Future<void> addNewAlarm({
    required double lat,
    required double lng,
    double radius = 500,
    String label = 'Nueva Alarma',
  }) async {
    final newAlarm = Alarm(
      id: const Uuid().v4(),
      latitude: lat,
      longitude: lng,
      radius: radius,
      label: label,
      isActive: true,
      createdAt: DateTime.now(),
    );

    final result = await addAlarmUseCase(newAlarm);
    result.fold(
      (failure) => emit(AlarmError(failure.message)),
      (_) {
        geofenceService.registerGeofence(newAlarm);
        loadAlarms();
      },
    );
  }

  Future<void> updateAlarmStatus(String id) async {
    final result = await toggleAlarmStatusUseCase(id);
    result.fold(
      (failure) => emit(AlarmError(failure.message)),
      (_) async {
        final alarms = await getAlarmsUseCase(NoParams());
        alarms.fold((_) => null, (list) {
          final alarm = list.firstWhere((a) => a.id == id);
          if (alarm.isActive) {
            geofenceService.registerGeofence(alarm);
          } else {
            geofenceService.removeGeofence(id);
          }
        });
        loadAlarms();
      },
    );
  }

  Future<void> deleteAlarm(String id) async {
    final result = await deleteAlarmUseCase(id);
    result.fold(
      (failure) => emit(AlarmError(failure.message)),
      (_) {
        geofenceService.removeGeofence(id);
        loadAlarms();
      },
    );
  }
}
