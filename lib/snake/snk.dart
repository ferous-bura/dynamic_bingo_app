import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/components.dart' hide Timer;
// import 'package:flame/components.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math';
import 'package:flame/components.dart' show Timer;

class SnakeGame extends FlameGame
    with TapDetector, HasKeyboardHandlerComponents {
  static const int gridSize = 20;
  static const double cellSize = 20.0;

  late final Snake snake;
  late final Food food;
  late final AudioPlayer audioPlayer;
  int score = 0;
  bool isGameOver = false;

  @override
  Future<void> onLoad() async {
    audioPlayer = AudioPlayer();
    snake = Snake();
    food = Food();

    // Add them to the game
    await add(snake);
    await add(food);

    // Wait for them to finish loading
    await Future.wait([snake.loaded, food.loaded]);

    // Now we can safely reset the game
    resetGame();
  }

  void resetGame() {
    isGameOver = false;
    score = 0;
    snake.reset();
    food.generate();
  }

  void gameOver() {
    isGameOver = true;
    audioPlayer.play(AssetSource('sounds/game_over.wav'));
  }

  void eatFood() {
    score++;
    audioPlayer.play(AssetSource('sounds/power.wav'));
    food.generate();
    snake.grow();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isGameOver) return;

    if (snake.head.position == food.position) {
      eatFood();
    }

    if (snake.checkCollision()) {
      gameOver();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    TextPaint(
      style: const TextStyle(color: Colors.white, fontSize: 24),
    ).render(canvas, 'Score: $score', Vector2(10, 10));
  }
}

class Snake extends PositionComponent with HasGameRef<SnakeGame> {
  static const double speed = 200.0;
  late final Sprite headSprite;
  late final Sprite bodySprite;
  late Timer timer;
  Direction direction = Direction.right;
  List<PositionComponent> body = [];

  PositionComponent get head => body.first;

  @override
  Future<void> onLoad() async {
    headSprite = await Sprite.load('snake_head.png');
    bodySprite = await Sprite.load('skin.png');

    timer = Timer(
      (1000 / speed).round() / 1000,
      repeat: true,
      onTick: () {
        final newHead =
            PositionComponent()..size = Vector2.all(SnakeGame.cellSize);

        switch (direction) {
          case Direction.up:
            newHead.position = Vector2(
              head.position.x,
              head.position.y - SnakeGame.cellSize,
            );
            break;
          case Direction.down:
            newHead.position = Vector2(
              head.position.x,
              head.position.y + SnakeGame.cellSize,
            );
            break;
          case Direction.left:
            newHead.position = Vector2(
              head.position.x - SnakeGame.cellSize,
              head.position.y,
            );
            break;
          case Direction.right:
            newHead.position = Vector2(
              head.position.x + SnakeGame.cellSize,
              head.position.y,
            );
            break;
        }

        body.insert(0, newHead);
        body.removeLast();
      },
    );

    reset();
  }

  void reset() {
    direction = Direction.right;
    body = [
      PositionComponent()
        ..position = Vector2(5 * SnakeGame.cellSize, 5 * SnakeGame.cellSize)
        ..size = Vector2.all(SnakeGame.cellSize),
    ];
    timer.start();
  }

  void grow() {
    body.add(
      PositionComponent()
        ..position = body.last.position
        ..size = Vector2.all(SnakeGame.cellSize),
    );
  }

  bool checkCollision() {
    final headPos = head.position;
    return headPos.x < 0 ||
        headPos.x >= gameRef.size.x ||
        headPos.y < 0 ||
        headPos.y >= gameRef.size.y ||
        body.sublist(1).any((segment) => segment.position == headPos);
  }

  @override
  void render(Canvas canvas) {
    for (var i = 0; i < body.length; i++) {
      final component = body[i];
      (i == 0 ? headSprite : bodySprite).render(
        canvas,
        position: component.position,
        size: component.size,
      );
    }
  }
}

class Food extends PositionComponent with HasGameRef<SnakeGame> {
  late final Sprite sprite;

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('apple.png');
    generate();
  }

  void generate() {
    position = Vector2(
      (Random().nextInt(SnakeGame.gridSize) * SnakeGame.cellSize).toDouble(),
      (Random().nextInt(SnakeGame.gridSize) * SnakeGame.cellSize).toDouble(),
    );
  }

  @override
  void render(Canvas canvas) {
    sprite.render(
      canvas,
      position: position,
      size: Vector2.all(SnakeGame.cellSize),
    );
  }
}

enum Direction { up, down, left, right }
