import 'package:flutter/material.dart';
import 'package:dynamic_bingo_app/game/api.dart';
import 'package:cached_network_image/cached_network_image.dart';

class GameDetailPage extends StatelessWidget {
  final Game game;

  const GameDetailPage({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(game.name)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'game-image-${game.name}', // Same tag as in HomePageContent
              child: CachedNetworkImage(
                imageUrl: game.image,
                width: double.infinity,
                height: 300,
                fit: BoxFit.cover,
                placeholder:
                    (context, url) => const CircularProgressIndicator(),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    game.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text('Next Game: ${game.nextGameTime}'),
                  const SizedBox(height: 8),
                  Text('Players: ${game.totalPlayers}'),
                  const SizedBox(height: 8),
                  Text('Prize: \$${game.prizeAmount}'),
                  const SizedBox(height: 8),
                  Text('Type: ${game.gameType}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
