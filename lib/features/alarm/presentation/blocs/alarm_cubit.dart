import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/alarm.dart';
import '../../domain/usecases/add_alarm.dart';
import '../../domain/usecases/delete_alarm.dart';
import '../../domain/usecases/get_alarms.dart';
import '../../domain/usecases/toggle_alarm_status.dart';
import '../../domain/usecases/update_alarm.dart';
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
  final UpdateAlarm updateAlarmUseCase;

  AlarmCubit({
    required this.addAlarmUseCase,
    required this.getAlarmsUseCase,
    required this.deleteAlarmUseCase,
    required this.toggleAlarmStatusUseCase,
    required this.geofenceService,
    required this.updateAlarmUseCase,
  }) : super(const AlarmInitial());

  // ... (previous methods)

  Future<void> updateExistingAlarm({
    required String id,
    required double lat,
    required double lng,
    required double radius,
    required String label,
    required bool isActive,
    required DateTime createdAt,
  }) async {
    try {
      final updatedAlarm = Alarm(
        id: id,
        latitude: lat,
        longitude: lng,
        radius: radius,
        label: label,
        isActive: isActive,
        createdAt: createdAt,
      );

      debugPrint('Actualizando alarma: ${updatedAlarm.label}');
      final result = await updateAlarmUseCase(updatedAlarm);
      result.fold(
        (failure) {
          debugPrint('Error al actualizar alarma: ${failure.message}');
          emit(AlarmError(failure.message));
        },
        (_) {
          debugPrint('Alarma actualizada exitosamente');
          // Actualizar geocerca
          if (updatedAlarm.isActive) {
            geofenceService.registerGeofence(updatedAlarm);
          } else {
            geofenceService.removeGeofence(updatedAlarm.id);
          }
          loadAlarms();
        },
      );
    } catch (e) {
      debugPrint('Error fatal al actualizar alarma: $e');
      emit(AlarmError(e.toString()));
    }
  }

  // ... (deleteAlarm)
  // ... (deleteAlarm)
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
    try {
      final newAlarm = Alarm(
        id: const Uuid().v4(),
        latitude: lat,
        longitude: lng,
        radius: radius,
        label: label,
        isActive: true,
        createdAt: DateTime.now(),
      );

      debugPrint('Agregando nueva alarma: ${newAlarm.label}');
      final result = await addAlarmUseCase(newAlarm);
      result.fold(
        (failure) {
          debugPrint('Error al agregar alarma (failure): ${failure.message}');
          emit(AlarmError(failure.message));
        },
        (_) {
          debugPrint('Alarma agregada exitosamente a la base de datos');
          geofenceService.registerGeofence(newAlarm);
          loadAlarms();
        },
      );
    } catch (e) {
      debugPrint('Error fatal al agregar alarma: $e');
      emit(AlarmError(e.toString()));
    }
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
