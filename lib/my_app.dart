import 'package:dynamic_bingo_app/snake/snake_game2.dart';
import 'package:dynamic_bingo_app/snake/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:dynamic_bingo_app/helpers/theme_helper.dart';
// import 'package:dynamic_bingo_app/helpers/web.dart';

import 'package:dynamic_bingo_app/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'dashboard_page.dart';
import 'user/login_page.dart';

import 'package:dynamic_bingo_app/auth.dart';
import 'package:dynamic_bingo_app/helpers/audio_player_helper.dart';
import 'package:dynamic_bingo_app/history_page.dart';

import 'package:flame/game.dart';
import 'snake/snake_game.dart';

class BingoApp extends StatefulWidget {
  const BingoApp({super.key});

  @override
  State<BingoApp> createState() => _BingoAppState();
}

class _BingoAppState extends State<BingoApp> {
  ThemeMode _themeMode = ThemeMode.light;

  // Key for saving/loading theme preference
  static const String _themePreferenceKey = 'theme_preference';

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  // Load the saved theme preference
  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString(_themePreferenceKey);

    setState(() {
      _themeMode = savedTheme == 'dark' ? ThemeMode.dark : ThemeMode.light;
    });
  }

  // Toggle between light and dark themes
  Future<void> _toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });

    // Save the selected theme preference
    await prefs.setString(
      _themePreferenceKey,
      _themeMode == ThemeMode.dark ? 'dark' : 'light',
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Bingo App',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _themeMode,
      home: LoginPage(),
      routes: {
        '/page1': (context) => DashboardPage(),
        '/page2': (context) => DashboardPage(),
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  String _appBarTitle = 'Home';
  String _currentTime = '';

  final List<Widget> _pages = [
    const HomePageContent(),
    const HistoryPage(),
    const BalancePage(),
    const SettingsPage(),
  ];

  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _updateTime();
  }

  void _updateTime() {
    setState(() {
      _currentTime = '${DateTime.now().hour}:${DateTime.now().minute}';
    });
    Future.delayed(const Duration(seconds: 1), _updateTime);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _appBarTitle = ['Home', 'History', 'Balance', 'Settings'][index];
      _pageController.jumpToPage(index); // Update the page view
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitle),
        actions: [
          TextButton(onPressed: () {}, child: Text(_currentTime)),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              AuthService authService = AuthService();
              await authService.logout(context);
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Drawer Header with Theme Toggle Icon
            UserAccountsDrawerHeader(
              accountName: const Text('John Doe'),
              accountEmail: const Text('john.doe@example.com'),
              currentAccountPicture: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Text('JD', style: TextStyle(fontSize: 40.0)),
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              otherAccountsPictures: [
                // Theme Toggle Icon
                IconButton(
                  icon: Icon(
                    Theme.of(context).brightness == Brightness.light
                        ? Icons
                            .brightness_4 // Light mode icon
                        : Icons.brightness_7, // Dark mode icon
                    color: Colors.white,
                  ),
                  onPressed: () {
                    // Toggle theme
                    final state =
                        context.findAncestorStateOfType<_BingoAppState>();
                    state?._toggleTheme();
                    // Close the drawer
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            ListTile(
              title: const Text('Score: 1000'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
              },
            ),
            ListTile(
              title: const Text('History'),
              onTap: () {
                _onItemTapped(1); // Update the selected index
                Future.delayed(const Duration(milliseconds: 300), () {
                  Navigator.pop(
                    context,
                  ); // Close the drawer after a slight delay
                });
              },
            ),
            ListTile(
              title: const Text('Balance'),
              onTap: () {
                _onItemTapped(2); // Update the selected index
                Future.delayed(const Duration(milliseconds: 300), () {
                  Navigator.pop(
                    context,
                  ); // Close the drawer after a slight delay
                });
              },
            ),
            ListTile(
              title: const Text('Settings'),
              onTap: () {
                _onItemTapped(3); // Update the selected index
                Future.delayed(const Duration(milliseconds: 300), () {
                  Navigator.pop(
                    context,
                  ); // Close the drawer after a slight delay
                });
              },
            ),
            ElevatedButton(
              onPressed: () async {
                // await AudioPlayerHelper.play(audio_url);
                await AudioPlayerHelper.play(
                  // 'assets/audio/special/start_game.mp3',
                  'assets/start_game.mp3',
                );
              },
              child: Text('Play Audio'),
            ),
          ],
        ),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
            _appBarTitle = ['Home', 'History', 'Balance', 'Settings'][index];
          });
        },
        children: _pages,
      ),
      bottomSheet: SizedBox(
        height: 70, // Height of the bottom sheet
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildBottomSheetItem(Icons.home, 'Home', 0),
            _buildBottomSheetItem(Icons.history, 'History', 1),
            _buildBottomSheetItem(Icons.account_balance, 'Balance', 2),
            _buildBottomSheetItem(Icons.settings, 'Settings', 3),
          ],
        ),
      ),
      // persistentFooterButtons: [
      //   ElevatedButton(
      //     onPressed: () {
      //       Navigator.push(
      //         context,
      //         MaterialPageRoute(
      //           builder:
      //               (context) => Scaffold(
      //                 appBar: AppBar(title: Text('WebView')),
      //                 body: WebViewExample(),
      //               ),
      //         ),
      //       );
      //     },
      //     child: Text('Open WebView'),
      //   ),
      //   ElevatedButton(onPressed: () {}, child: Text('serttings')),
      // ],
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 70.0),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) => Scaffold(
                      appBar: AppBar(title: Text('API Example')),
                      body: Placeholder(),
                    ),
              ),
            );
          },
          child: Icon(Icons.add_circle_outlined),
        ),
      ),
    );
  }

  Widget _buildBottomSheetItem(IconData icon, String label, int index) {
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: _selectedIndex == index ? Colors.blue : Colors.grey,
          ),
          Text(
            label,
            style: TextStyle(
              color: _selectedIndex == index ? Colors.blue : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

class MyApp3 extends StatelessWidget {
  const MyApp3({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(debugShowCheckedModeBanner: false, home: snake());
  }
}

class MyApp2 extends StatelessWidget {
  const MyApp2({super.key});

  @override
  Widget build(BuildContext context) {
    final game = SnakeGame();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,

      home: Scaffold(
        body: Stack(
          children: [
            GameWidget(game: game),
            Positioned(
              bottom: 20,
              left: 20,
              child: Column(
                children: [
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed:
                            () => game.snake.changeDirection(Direction.up),
                        child: const Text("↑"),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed:
                            () => game.snake.changeDirection(Direction.left),
                        child: const Text("←"),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed:
                            () => game.snake.changeDirection(Direction.right),
                        child: const Text("→"),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed:
                            () => game.snake.changeDirection(Direction.down),
                        child: const Text("↓"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GameOverlay extends StatelessWidget {
  final SnakeGame game;
  const GameOverlay(this.game, {super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 10,
          left: 10,
          child: Text(
            "Score: ${game.score}",
            style: const TextStyle(fontSize: 24, color: Colors.white),
          ),
        ),
        Positioned(
          top: 10,
          right: 10,
          child: Text(
            "Time: ${game.timeLeft}",
            style: const TextStyle(fontSize: 24, color: Colors.red),
          ),
        ),
      ],
    );
  }
}
