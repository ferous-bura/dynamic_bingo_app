import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui; // For Image and Canvas

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For rootBundle

class SnakeGame extends StatefulWidget {
  const SnakeGame({super.key});

  @override
  _SnakeGameState createState() => _SnakeGameState();
}

class _SnakeGameState extends State<SnakeGame> {
  static const int gridSize = 20;
  static const double initialSpeed = 600.0; // Faster speed

  double cellSize = 20.0; // Adjust the initial size as needed
  late double snakeSpeed;

  List<Offset> snake = [Offset(5, 5)];
  Offset food = Offset(10, 10);
  Direction direction = Direction.right;
  Timer? timer;
  int score = 0;
  bool isGameRunning = false;

  // Images for snake head and food
  ui.Image? snakeHeadImage;
  ui.Image? foodImage;

  @override
  void initState() {
    super.initState();
    snakeSpeed = initialSpeed;
    loadImages();
  }

  // Load images from assets
  void loadImages() async {
    snakeHeadImage = await loadImage('assets/snake.png');
    foodImage = await loadImage('assets/apple.png');
    setState(() {}); // Trigger a rebuild to display the images
  }

  // Helper function to load an image
  Future<ui.Image> loadImage(String assetPath) async {
    final ByteData data = await rootBundle.load(assetPath);
    final ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
    );
    final ui.FrameInfo frame = await codec.getNextFrame();
    return frame.image;
  }

  void startGame() {
    if (!isGameRunning) {
      setState(() {
        isGameRunning = true;
        snake = [Offset(5, 5)];
        direction = Direction.right;
        score = 0;
        snakeSpeed = initialSpeed;
        generateFood();
        timer = Timer.periodic(Duration(milliseconds: snakeSpeed.toInt()), (
          Timer t,
        ) {
          moveSnake();
          checkCollision();
        });
      });
    }
  }

  void generateFood() {
    final Random rand = Random();
    Offset newFood;

    do {
      newFood = Offset(
        rand.nextInt(gridSize).toDouble(),
        rand.nextInt(gridSize).toDouble(),
      );
    } while (snake.contains(newFood));

    food = newFood;
  }

  void moveSnake() {
    setState(() {
      switch (direction) {
        case Direction.up:
          snake.insert(0, Offset(snake.first.dx, snake.first.dy - 1));
          break;
        case Direction.down:
          snake.insert(0, Offset(snake.first.dx, snake.first.dy + 1));
          break;
        case Direction.left:
          snake.insert(0, Offset(snake.first.dx - 1, snake.first.dy));
          break;
        case Direction.right:
          snake.insert(0, Offset(snake.first.dx + 1, snake.first.dy));
          break;
      }

      if (snake.first == food) {
        generateFood();
        score++;
        snakeSpeed *=
            0.95; // Make the game slightly faster with each food eaten
        timer?.cancel();
        timer = Timer.periodic(Duration(milliseconds: snakeSpeed.toInt()), (
          Timer t,
        ) {
          moveSnake();
          checkCollision();
        });
      } else {
        snake.removeLast();
      }
    });
  }

  void checkCollision() {
    if (snake.first.dx < 0 ||
        snake.first.dx >= gridSize ||
        snake.first.dy < 0 ||
        snake.first.dy >= gridSize ||
        snake.sublist(1).contains(snake.first)) {
      // Game Over
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Game Over'),
            content: Text('Your score: $score'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  stopGame();
                },
                child: Text('Play Again'),
              ),
            ],
          );
        },
      );
      stopGame();
    }
  }

  void stopGame() {
    setState(() {
      isGameRunning = false;
      timer?.cancel();
    });
  }

  void changeDirection(Direction newDirection) {
    if ((direction == Direction.up && newDirection != Direction.down) ||
        (direction == Direction.down && newDirection != Direction.up) ||
        (direction == Direction.left && newDirection != Direction.right) ||
        (direction == Direction.right && newDirection != Direction.left)) {
      setState(() {
        direction = newDirection;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    cellSize = screenWidth / gridSize;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 235, 235, 235),
        centerTitle: true,
        title: Text(
          'Snakeee',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(screenWidth * 0.02),
            child: Text(
              'Score: $score',
              style: TextStyle(
                fontSize: screenWidth * 0.04,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Color.fromARGB(255, 13, 58, 19)),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: [
                      CustomPaint(
                        painter: BoundaryPainter(gridSize, cellSize),
                        size: Size(constraints.maxWidth, constraints.maxWidth),
                      ),
                      CustomPaint(
                        painter: SnakePainter(
                          snake,
                          food,
                          gridSize,
                          cellSize,
                          snakeHeadImage,
                          foodImage,
                        ),
                        size: Size(constraints.maxWidth, constraints.maxWidth),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          // Control Buttons
          Padding(
            padding: EdgeInsets.only(bottom: screenWidth * 0.1),
            child: Column(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_upward, size: 40),
                  onPressed: () => changeDirection(Direction.up),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, size: 40),
                      onPressed: () => changeDirection(Direction.left),
                    ),
                    SizedBox(width: 60),
                    IconButton(
                      icon: Icon(Icons.arrow_forward, size: 40),
                      onPressed: () => changeDirection(Direction.right),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.arrow_downward, size: 40),
                  onPressed: () => changeDirection(Direction.down),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: startGame,
            child: Text('Start', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }
}

class SnakePainter extends CustomPainter {
  final List<Offset> snake;
  final Offset food;
  final int gridSize;
  final double cellSize;
  final ui.Image? snakeHeadImage;
  final ui.Image? foodImage;

  SnakePainter(
    this.snake,
    this.food,
    this.gridSize,
    this.cellSize,
    this.snakeHeadImage,
    this.foodImage,
  );

  @override
  void paint(Canvas canvas, Size size) {
    // Draw snake
    for (int i = 0; i < snake.length; i++) {
      final position = snake[i];
      if (i == 0 && snakeHeadImage != null) {
        // Draw snake head
        canvas.drawImageRect(
          snakeHeadImage!,
          Rect.fromLTWH(
            0,
            0,
            snakeHeadImage!.width.toDouble(),
            snakeHeadImage!.height.toDouble(),
          ),
          Rect.fromPoints(
            Offset(position.dx * cellSize, position.dy * cellSize),
            Offset((position.dx + 1) * cellSize, (position.dy + 1) * cellSize),
          ),
          Paint(),
        );
      } else {
        // Draw snake body
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromPoints(
              Offset(position.dx * cellSize, position.dy * cellSize),
              Offset(
                (position.dx + 1) * cellSize,
                (position.dy + 1) * cellSize,
              ),
            ),
            Radius.circular(cellSize / 2),
          ),
          Paint()..color = Colors.green,
        );
      }
    }

    // Draw food
    if (foodImage != null) {
      canvas.drawImageRect(
        foodImage!,
        Rect.fromLTWH(
          0,
          0,
          foodImage!.width.toDouble(),
          foodImage!.height.toDouble(),
        ),
        Rect.fromPoints(
          Offset(food.dx * cellSize, food.dy * cellSize),
          Offset((food.dx + 1) * cellSize, (food.dy + 1) * cellSize),
        ),
        Paint(),
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class BoundaryPainter extends CustomPainter {
  final int gridSize;
  final double cellSize;

  BoundaryPainter(this.gridSize, this.cellSize);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint boundaryPaint =
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill;

    // Draw rounded squares for boundaries
    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromPoints(
              Offset(i * cellSize, j * cellSize),
              Offset((i + 1) * cellSize, (j + 1) * cellSize),
            ),
            Radius.circular(cellSize / 4),
          ),
          boundaryPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

enum Direction { up, down, left, right }
