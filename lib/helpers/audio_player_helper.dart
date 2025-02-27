import 'package:audioplayers/audioplayers.dart';

class AudioPlayerHelper {
  static final AudioPlayer _audioPlayer = AudioPlayer();

  static Future<void> play(String url) async {
    try {
      print('Attempting to play audio from: $url');
      await _audioPlayer.play(UrlSource(url));
      print('Audio playback started successfully');
    } catch (e) {
      print('Failed to play audio: $e');
    }
  }

  static Future<void> pause() async {
    try {
      await _audioPlayer.pause();
      print('Audio paused');
    } catch (e) {
      print('Failed to pause audio: $e');
    }
  }

  static Future<void> stop() async {
    try {
      await _audioPlayer.stop();
      print('Audio stopped');
    } catch (e) {
      print('Failed to stop audio: $e');
    }
  }
}
