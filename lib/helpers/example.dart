import 'package:flutter/material.dart';
import './shared_preferences_helper.dart';
import './http_helper.dart';
import './audio_player_helper.dart';
import './web.dart';
import './theme_helper.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.light,
      themeMode: ThemeMode.system,
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Utility Demo')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                await SharedPreferencesHelper.saveString('username', 'JohnDoe');
                String? username = await SharedPreferencesHelper.getString(
                  'username',
                );
                print('Username: $username');
              },
              child: Text('Shared Preferences'),
            ),
            ElevatedButton(
              onPressed: () async {
                String data = await HttpHelper.get(
                  'https://jsonplaceholder.typicode.com/posts',
                );
                print('GET Response: $data');
              },
              child: Text('HTTP GET'),
            ),
            ElevatedButton(
              onPressed: () async {
                // await AudioPlayerHelper.play(audio_url);
                await AudioPlayerHelper.play(
                  'assets/audio/special/start_game.mp3',
                );
              },
              child: Text('Play Audio'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => Scaffold(
                          appBar: AppBar(title: Text('WebView')),
                          body: WebViewExample(),
                        ),
                  ),
                );
              },
              child: Text('Open WebView'),
            ),
          ],
        ),
      ),
    );
  }
}
