import 'dart:math';
import 'package:flame/game.dart';
import 'package:flame/components.dart' hide Timer;
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'dart:async';

enum Direction { up, down, left, right }

class SnakeSegment extends SpriteComponent {
  SnakeSegment(Vector2 pos) : super(position: pos, size: Vector2(20, 20));

  @override
  Future<void> onLoad() async {
    super.onLoad();
    sprite = await Sprite.load("snake.png"); // Load from assets
  }
}

class SnakeGame extends FlameGame with HasKeyboardHandlerComponents {
  late Snake snake;
  late Food food;
  List<Fence> fences = [];
  int score = 0;
  int timeLeft = 60; // 60 seconds countdown
  Timer? gameTimer;

  void checkWinCondition() {
    if (score >= 20) {
      gameTimer?.cancel(); // Stop the timer
      print("🎉 You win! 🎉");
      showWinScreen();
    }
  }

  void showWinScreen() {
    // Show a simple message when winning
    overlays.add('winOverlay'); // Create an overlay in Flutter UI
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    snake = Snake();
    food = Food();

    // Add fences in random locations
    for (int i = 0; i < 5; i++) {
      fences.add(
        Fence(Vector2(Random().nextInt(10) * 20, Random().nextInt(10) * 20)),
      );
    }
    addAll(fences);
    add(snake);
    add(food);
    startTimer();
  }

  void gameOver() {
    gameTimer?.cancel(); // Ensure timer stops when game ends
    print("💀 Game Over! Try again.");
    overlays.add('gameOverOverlay'); // Show Game Over UI (Optional)
  }

  void startTimer() {
    gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timeLeft > 0) {
        timeLeft--;
      } else {
        timer.cancel(); // This will work correctly now
        gameOver(); // Call game over function
      }
    });
  }

  void spawnFood() {
    food.position = Vector2(
      (Random().nextInt(10) * 20).toDouble(),
      (Random().nextInt(10) * 20).toDouble(),
    );
  }
}

class Snake extends PositionComponent with HasGameRef<SnakeGame> {
  Direction direction = Direction.right;
  final List<Vector2> body = [Vector2(100, 100)];
  double moveTimer = 0.0;

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = Colors.green;
    for (var segment in body) {
      canvas.drawRect(Rect.fromLTWH(segment.x, segment.y, 20, 20), paint);
    }
  }

  @override
  void update(double dt) {
    moveTimer += dt;
    if (moveTimer > 0.2) {
      moveSnake();
      moveTimer = 0.0;
    }
  }

  void gameOverWithAnimation() {
    for (int i = 0; i < 3; i++) {
      Future.delayed(Duration(milliseconds: 200 * i), () {
        body.first = Vector2(body.first.x, body.first.y); // Flash effect
      });
    }
    Future.delayed(Duration(seconds: 1), () {
      body.clear();
      body.add(Vector2(100, 100)); // Restart
    });
  }

  void moveSnake() {
    Vector2 newHead = body.first.clone();

    switch (direction) {
      case Direction.up:
        newHead.y -= 20;
        if (newHead.y < 0) {
          newHead.y = gameRef.size.y - 20; // Teleport from top to bottom
        }
        break;
      case Direction.down:
        newHead.y += 20;
        if (newHead.y >= gameRef.size.y) {
          newHead.y = 0; // Teleport from bottom to top
        }
        break;
      case Direction.left:
        newHead.x -= 20;
        if (newHead.x < 0) {
          newHead.x = gameRef.size.x - 20; // Teleport from left to right
        }
        break;
      case Direction.right:
        newHead.x += 20;
        if (newHead.x >= gameRef.size.x) {
          newHead.x = 0; // Teleport from right to left
        }
        break;
    }

    // Check if snake hits an obstacle (fence)
    if (gameRef.fences.any((fence) => fence.position == newHead)) {
      gameOverWithAnimation();
      return;
    }

    // Check if snake eats food
    if (newHead == gameRef.food.position) {
      grow();
      gameRef.score++; // Increase score
      gameRef.checkWinCondition(); // Check if the player wins
      gameRef.spawnFood(); // Spawn new food
    }

    // Move the snake
    body.insert(0, newHead);
    body.removeLast();
  }

  void grow() {
    body.add(body.last.clone());
  }

  void gameOver() {
    body.clear();
    body.add(Vector2(100, 100)); // Reset snake
  }

  void changeDirection(Direction newDirection) {
    if ((direction == Direction.up && newDirection == Direction.down) ||
        (direction == Direction.down && newDirection == Direction.up) ||
        (direction == Direction.left && newDirection == Direction.right) ||
        (direction == Direction.right && newDirection == Direction.left)) {
      return;
    }
    direction = newDirection;
  }
}

class Food extends PositionComponent {
  Food() {
    position = Vector2(60, 60);
    size = Vector2(20, 20);
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = Colors.red;
    canvas.drawRect(size.toRect(), paint);
  }
}

class Fence extends PositionComponent {
  Fence(Vector2 pos) {
    position = pos;
    size = Vector2(20, 20);
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = Colors.brown;
    canvas.drawRect(size.toRect(), paint);
  }
}
