import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class PlayAudioPage extends StatefulWidget {
  const PlayAudioPage({super.key});

  @override
  _PlayAudioPageState createState() => _PlayAudioPageState();
}

class _PlayAudioPageState extends State<PlayAudioPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  // The URL of the audio file hosted on your local Django server
  final String audioUrl =
      'http://127.0.0.1:8000/static/bingo_static/audio/special/start_game.mp3';

  // Function to play audio
  Future<void> _playAudio() async {
    try {
      // Play the audio
      await _audioPlayer.play(audioUrl as Source);

      setState(() {
        _isPlaying = true;
      });
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  // Function to stop the audio
  Future<void> _stopAudio() async {
    await _audioPlayer.stop();
    setState(() {
      _isPlaying = false;
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Play Audio')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _isPlaying ? null : _playAudio,
              child: Text('Play Game Start Sound'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: !_isPlaying ? null : _stopAudio,
              child: Text('Stop Audio'),
            ),
          ],
        ),
      ),
    );
  }
}
