import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:geo_alarm/core/services/i_audio_service.dart';

@LazySingleton(as: IAudioService)
class AudioServiceImpl implements IAudioService {
  final _player = AudioPlayer();

  @override
  Future<void> playAlarmLoop() async {
    try {
      await _player.setReleaseMode(ReleaseMode.loop);
      // Assuming we have an asset named 'alarm.mp3'
      await _player.play(AssetSource('sounds/alarm.mp3'));
    } catch (e) {
      // Log error but don't crash
      debugPrint('Error al reproducir alarma: $e');
    }
  }

  @override
  Future<void> stopAlarm() async {
    await _player.stop();
  }
}
