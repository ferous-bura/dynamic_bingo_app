// import 'package:dynamic_bingo_app/helpers/web.dart';
// import 'package:dynamic_bingo_app/my_app.dart';
import 'package:dynamic_bingo_app/snake/splash_screen.dart';
// import 'package:dynamic_bingo_app/snake/snake_game3.dart';
// import 'package:flame/game.dart';

import 'package:flutter/material.dart';

// import 'snake/snk.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   // runApp(BingoApp());

//   runApp(const MyApp());
//   // runApp(WebViewExample());
// }

void main() {
  // final game = SnakeGame();

  // runApp(GameWidget(game: game));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Snake Game',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Color.fromARGB(255, 13, 58, 19),
        primaryColor: Colors.green,
        hintColor: Colors.red,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
        ),
      ),
      home: SplashScreen(),
    );
  }
}

/*
adb tcpip 5555
adb devices
adb connect 192.168.125.199:5555
adb connect 10.171.186.116:5555

flutter clean
flutter pub get
flutter run

 91:b7:38:da:d3:d5:91:c6:ea:48:c2:3a:a0:33:80:c0:72:df:0e:a4
 */
