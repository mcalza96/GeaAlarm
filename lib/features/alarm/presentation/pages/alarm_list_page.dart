import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/alarm_cubit.dart';
import '../blocs/alarm_state.dart';
import '../domain/entities/alarm.dart';
import 'map_page.dart';
import 'developer_mode_page.dart';

class AlarmListPage extends StatelessWidget {
  const AlarmListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis GeoAlarmas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DeveloperModePage()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.map),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MapPage()),
            ),
          ),
        ],
      ),
      body: BlocBuilder<AlarmCubit, AlarmState>(
        builder: (context, state) {
          if (state is AlarmLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is AlarmsLoaded) {
            if (state.alarms.isEmpty) {
              return const Center(
                child: Text('No tienes alarmas configuradas.'),
              );
            }
            return ListView.builder(
              itemCount: state.alarms.length,
              itemBuilder: (context, index) {
                final alarm = state.alarms[index];
                return _AlarmTile(alarm: alarm);
              },
            );
          } else if (state is AlarmError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return const Center(child: Text('Iniciando...'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MapPage()),
        ),
        child: const Icon(Icons.add_location_alt),
      ),
    );
  }
}

class _AlarmTile extends StatelessWidget {
  final Alarm alarm;

  const _AlarmTile({required this.alarm});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(alarm.label),
      subtitle: Text('Radio: ${alarm.radius.toInt()}m'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Switch(
            value: alarm.isActive,
            onChanged: (_) =>
                context.read<AlarmCubit>().updateAlarmStatus(alarm.id),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => context.read<AlarmCubit>().deleteAlarm(alarm.id),
          ),
        ],
      ),
    );
  }
}
