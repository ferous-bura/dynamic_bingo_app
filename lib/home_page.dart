import 'package:dynamic_bingo_app/game_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:dynamic_bingo_app/game/api.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HomePageContent extends StatefulWidget {
  const HomePageContent({super.key});

  @override
  State<HomePageContent> createState() => _HomePageContentState();
}

class _HomePageContentState extends State<HomePageContent> {
  late Future<List<Game>> _futureGames;

  @override
  void initState() {
    super.initState();
    _futureGames = ApiService().fetchGames();
  }

  Future<void> _refreshData() async {
    setState(() {
      _futureGames = ApiService().fetchGames();
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: FutureBuilder<List<Game>>(
        future: _futureGames,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No data available'));
          } else {
            final games = snapshot.data!;
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: games.length,
              itemBuilder: (context, index) {
                Game game = games[index];
                return GestureDetector(
                  onTap: () {
                    // Navigate to the detail page with Hero animation
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder:
                            (context, animation, secondaryAnimation) =>
                                GameDetailPage(game: game),
                        transitionsBuilder: (
                          context,
                          animation,
                          secondaryAnimation,
                          child,
                        ) {
                          const begin = Offset(1.0, 0.0); // Slide from right
                          const end = Offset.zero;
                          const curve = Curves.easeInOut;
                          var tween = Tween(
                            begin: begin,
                            end: end,
                          ).chain(CurveTween(curve: curve));
                          var offsetAnimation = animation.drive(tween);
                          // var scaleAnimation = animation.drive(tween);
                          return SlideTransition(
                            position: offsetAnimation,
                            child: child,
                          );
                        },
                      ),
                    );
                  },
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.4,
                    child: Card(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Hero(
                              tag:
                                  'game-image-${game.name}', // Unique tag for Hero
                              child: CachedNetworkImage(
                                imageUrl: game.image,
                                placeholder:
                                    (context, url) =>
                                        const CircularProgressIndicator(),
                                errorWidget:
                                    (context, url, error) =>
                                        const Icon(Icons.error),
                              ),
                            ),
                            Text(game.name),
                            Text('Next Game: ${game.nextGameTime}'),
                            Text('Players: ${game.totalPlayers}'),
                            Text('Prize: \$${game.prizeAmount}'),
                            Text('Type: ${game.gameType}'),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
