import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/map_cubit.dart';
import '../blocs/map_state.dart';
import '../blocs/alarm_cubit.dart';

class AlarmSetupSheet extends StatelessWidget {
  const AlarmSetupSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: BlocBuilder<MapCubit, MapState>(
        builder: (context, state) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                state.editingAlarmId != null
                    ? 'Editar Alarma'
                    : 'Configurar Alarma',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              if (state.isLoadingAddress)
                const LinearProgressIndicator()
              else
                Text(
                  state.currentAddress ?? 'Dirección no encontrada',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              const SizedBox(height: 24),
              Text(
                'Radio de la geocerca: ${state.currentRadius.toInt()} metros',
                style: Theme.of(context).textTheme.labelLarge,
              ),
              Slider(
                value: state.currentRadius,
                min: 100,
                max: 2000,
                divisions: 19,
                label: '${state.currentRadius.toInt()}m',
                onChanged: (value) =>
                    context.read<MapCubit>().updateRadius(value),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        context.read<MapCubit>().resetSelection();
                        Navigator.pop(context);
                      },
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: state.selectedLocation != null
                          ? () {
                              if (state.editingAlarmId != null) {
                                context.read<AlarmCubit>().updateExistingAlarm(
                                      id: state.editingAlarmId!,
                                      lat: state.selectedLocation!.latitude,
                                      lng: state.selectedLocation!.longitude,
                                      radius: state.currentRadius,
                                      label:
                                          state.currentAddress ?? 'Mi Destino',
                                      isActive:
                                          state.editingAlarmIsActive ?? true,
                                      createdAt: state.editingAlarmCreatedAt ??
                                          DateTime.now(),
                                    );
                              } else {
                                context.read<AlarmCubit>().addNewAlarm(
                                      lat: state.selectedLocation!.latitude,
                                      lng: state.selectedLocation!.longitude,
                                      radius: state.currentRadius,
                                      label:
                                          state.currentAddress ?? 'Mi Destino',
                                    );
                              }
                              context.read<MapCubit>().resetSelection();
                              Navigator.pop(context);
                            }
                          : null,
                      child: Text(state.editingAlarmId != null
                          ? 'Actualizar Alarma'
                          : 'Confirmar Alarma'),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
