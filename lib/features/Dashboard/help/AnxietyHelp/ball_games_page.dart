import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:math';

class BallGamesPage extends StatefulWidget {
  const BallGamesPage({super.key});

  @override
  State<BallGamesPage> createState() => _BallGamesPageState();
}

class _BallGamesPageState extends State<BallGamesPage>
    with TickerProviderStateMixin {
  List<Ball> balls = [];
  int score = 0;
  int poppedBalls = 0;
  late AnimationController _animationController;
  final Random random = Random();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 50),
      vsync: this,
    );
    _generateBalls();
    _startBallMovement();
  }

  void _generateBalls() {
    balls.clear();
    for (int i = 0; i < 8; i++) {
      balls.add(Ball(
        id: i,
        x: random.nextDouble() * 300,
        y: random.nextDouble() * 400 + 100,
        color: _getRandomColor(),
        size: random.nextDouble() * 30 + 20,
        speedX: (random.nextDouble() - 0.5) * 4,
        speedY: (random.nextDouble() - 0.5) * 4,
      ));
    }
  }

  Color _getRandomColor() {
    List<Color> colors = [
      const Color(0xff8654B0),
      const Color(0xff9B59B6),
      const Color(0xffAB47BC),
      const Color(0xffBA68C8),
      const Color(0xffCE93D8),
      const Color(0xff7B1FA2),
    ];
    return colors[random.nextInt(colors.length)];
  }

  void _startBallMovement() {
    _animationController.addListener(() {
      setState(() {
        for (var ball in balls) {
          ball.x += ball.speedX;
          ball.y += ball.speedY;

          // Bounce off walls
          if (ball.x <= 0 || ball.x >= 350) {
            ball.speedX *= -1;
          }
          if (ball.y <= 0 || ball.y >= 500) {
            ball.speedY *= -1;
          }
        }
      });
    });
    _animationController.repeat();
  }

  void _popBall(int ballId) {
    setState(() {
      balls.removeWhere((ball) => ball.id == ballId);
      poppedBalls++;
      score += 10;
    });

    if (balls.isEmpty) {
      _showCompletionDialog();
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: const Color(0xff491475),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.celebration,
                  color: Colors.yellow,
                  size: 64,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Great Job!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'You popped all the balls!\nScore: $score',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _resetGame();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff8654B0),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Play Again'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          GoRouter.of(context).go('/dashboard/help/anxiety');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Back'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _resetGame() {
    setState(() {
      score = 0;
      poppedBalls = 0;
    });
    _generateBalls();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff280446), // primaryD
      appBar: AppBar(
        backgroundColor: const Color(0xff18002D), // headerD
        title: const Text(
          'Ball Games',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => GoRouter.of(context).go('/dashboard/help/anxiety'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _resetGame,
          ),
        ],
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Score Section
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xff491475), // containerD
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text(
                        'Score',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      Text(
                        '$score',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  Column(
                    children: [
                      const Text(
                        'Popped',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      Text(
                        '$poppedBalls',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  Column(
                    children: [
                      const Text(
                        'Remaining',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      Text(
                        '${balls.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Instructions
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Tap the bouncing balls to pop them! 🎈\nFocus on the movement to calm your mind',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // Game Area
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xff491475).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 2,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: Stack(
                      children: balls.map((ball) {
                        return Positioned(
                          left: ball.x,
                          top: ball.y,
                          child: GestureDetector(
                            onTap: () => _popBall(ball.id),
                            child: Container(
                              width: ball.size,
                              height: ball.size,
                              decoration: BoxDecoration(
                                color: ball.color,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: ball.color.withOpacity(0.5),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.sports_basketball,
                                  color: Colors.white.withOpacity(0.8),
                                  size: ball.size * 0.6,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}

class Ball {
  int id;
  double x;
  double y;
  Color color;
  double size;
  double speedX;
  double speedY;

  Ball({
    required this.id,
    required this.x,
    required this.y,
    required this.color,
    required this.size,
    required this.speedX,
    required this.speedY,
  });
}