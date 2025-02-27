import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for LogicalKeyboardKey
import 'package:flame/game.dart';
import 'package:flame/input.dart'; // Import for TapDownInfo
import 'package:flame/events.dart'; // Import for TapDownInfo
import 'dart:math';

class SnakeGame extends FlameGame
    with TapDetector, HasKeyboardHandlerComponents {
  final int squaresPerRow = 20;
  final int squaresPerCol = 40;
  final randomGen = Random();

  late List<Vector2> snake;
  late Vector2 food;
  late String direction;
  late bool isPlaying;

  @override
  Future<void> onLoad() async {
    await super.onLoad(); // Ensure `size` is set before rendering
    startGame();
  }

  void startGame() {
    snake = [
      Vector2(
        (squaresPerRow / 2).floorToDouble(),
        (squaresPerCol / 2).floorToDouble(),
      ),
      Vector2(
        (squaresPerRow / 2).floorToDouble(),
        (squaresPerCol / 2).floorToDouble() - 1,
      ),
    ];
    direction = 'up';
    isPlaying = true;
    createFood();
  }

  void createFood() {
    food = Vector2(
      randomGen.nextInt(squaresPerRow).toDouble(),
      randomGen.nextInt(squaresPerCol).toDouble(),
    );
  }

  void moveSnake() {
    if (!isPlaying) return;

    Vector2 newHead;
    switch (direction) {
      case 'up':
        newHead = Vector2(snake.first.x, snake.first.y - 1);
        break;
      case 'down':
        newHead = Vector2(snake.first.x, snake.first.y + 1);
        break;
      case 'left':
        newHead = Vector2(snake.first.x - 1, snake.first.y);
        break;
      case 'right':
        newHead = Vector2(snake.first.x + 1, snake.first.y);
        break;
      default:
        return;
    }

    // Check for collisions
    if (newHead.x < 0 ||
        newHead.x >= squaresPerRow ||
        newHead.y < 0 ||
        newHead.y >= squaresPerCol ||
        snake.any((segment) => segment == newHead)) {
      endGame();
      return;
    }

    snake.insert(0, newHead);

    if (newHead == food) {
      createFood();
    } else {
      snake.removeLast();
    }
  }

  void endGame() {
    isPlaying = false;
    if (!overlays.isActive('GameOver')) {
      overlays.add('GameOver');
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isPlaying) {
      moveSnake();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (size.x == 0 || size.y == 0) {
      return; // Prevent errors if `size` is not set
    }

    final cellSize = size.x / squaresPerRow;

    // Draw snake
    for (var segment in snake) {
      canvas.drawCircle(
        Offset(
          segment.x * cellSize + cellSize / 2,
          segment.y * cellSize + cellSize / 2,
        ),
        cellSize / 2,
        Paint()..color = Colors.green,
      );
    }

    // Draw food
    canvas.drawCircle(
      Offset(
        food.x * cellSize + cellSize / 2,
        food.y * cellSize + cellSize / 2,
      ),
      cellSize / 2,
      Paint()..color = Colors.red,
    );
  }

  @override
  void onTapDown(TapDownInfo info) {
    if (!isPlaying) {
      startGame();
      overlays.remove('GameOver');
    }
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    var result = super.onKeyEvent(event, keysPressed); // Call super

    if (keysPressed.contains(LogicalKeyboardKey.arrowUp)) {
      direction = 'up';
    } else if (keysPressed.contains(LogicalKeyboardKey.arrowDown)) {
      direction = 'down';
    } else if (keysPressed.contains(LogicalKeyboardKey.arrowLeft)) {
      direction = 'left';
    } else if (keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
      direction = 'right';
    }

    return KeyEventResult.handled;
  }
}

class GameOverOverlay extends StatelessWidget {
  final SnakeGame game;

  const GameOverOverlay(this.game, {super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Game Over',
            style: TextStyle(
              color: Colors.red,
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Score: ${game.snake.length - 2}',
            style: TextStyle(
              color: Colors.orange,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          ElevatedButton(
            onPressed: () {
              game.startGame();
              game.overlays.remove('GameOver');
            },
            child: Text('Restart'),
          ),
        ],
      ),
    );
  }
}
