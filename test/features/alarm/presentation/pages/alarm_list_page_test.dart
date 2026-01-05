import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:geo_alarm/features/alarm/presentation/blocs/alarm_cubit.dart';
import 'package:geo_alarm/features/alarm/presentation/blocs/alarm_state.dart';
import 'package:geo_alarm/features/alarm/presentation/pages/alarm_list_page.dart';
import 'package:geo_alarm/features/alarm/domain/entities/alarm.dart';

class MockAlarmCubit extends Mock implements AlarmCubit {}

void main() {
  late MockAlarmCubit mockAlarmCubit;

  setUp(() {
    mockAlarmCubit = MockAlarmCubit();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<AlarmCubit>.value(
        value: mockAlarmCubit,
        child: const AlarmListPage(),
      ),
    );
  }

  testWidgets('Should display empty state when no alarms are loaded',
      (tester) async {
    when(() => mockAlarmCubit.state).thenReturn(const AlarmsLoaded([]));
    when(() => mockAlarmCubit.stream).thenAnswer((_) => const Stream.empty());

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('No tienes alarmas configuradas.'), findsOneWidget);
  });

  testWidgets('Should display a list of alarms when loaded', (tester) async {
    final alarms = [
      Alarm(
        id: '1',
        latitude: 0,
        longitude: 0,
        radius: 500,
        label: 'Casa',
        isActive: true,
        createdAt: DateTime.now(),
      ),
    ];

    when(() => mockAlarmCubit.state).thenReturn(AlarmsLoaded(alarms));
    when(() => mockAlarmCubit.stream).thenAnswer((_) => const Stream.empty());

    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('Casa'), findsOneWidget);
    expect(find.text('Radio: 500m'), findsOneWidget);
  });
}
