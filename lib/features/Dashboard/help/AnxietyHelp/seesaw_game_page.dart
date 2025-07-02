import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:math';

class SeeSawGamePage extends StatefulWidget {
  const SeeSawGamePage({super.key});

  @override
  State<SeeSawGamePage> createState() => _SeeSawGamePageState();
}

class _SeeSawGamePageState extends State<SeeSawGamePage>
    with TickerProviderStateMixin {
  double seeSawAngle = 0.0;
  double targetAngle = 0.0;
  int score = 0;
  int level = 1;
  bool isBalanced = false;
  double balanceTime = 0.0;
  
  late AnimationController _balanceController;
  late AnimationController _breathingController;
  late Animation<double> _breathingAnimation;
  
  List<Weight> leftWeights = [];
  List<Weight> rightWeights = [];
  
  final Random random = Random();

  @override
  void initState() {
    super.initState();
    
    _balanceController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    
    _breathingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    
    _breathingAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _breathingController,
      curve: Curves.easeInOut,
    ));
    
    _breathingController.repeat(reverse: true);
    
    _generateWeights();
    _startBalanceCheck();
  }

  void _generateWeights() {
    leftWeights.clear();
    rightWeights.clear();
    
    // Generate random weights for the current level
    int numWeights = 2 + level;
    for (int i = 0; i < numWeights; i++) {
      if (random.nextBool()) {
        leftWeights.add(Weight(
          value: random.nextInt(5) + 1,
          color: _getRandomColor(),
        ));
      } else {
        rightWeights.add(Weight(
          value: random.nextInt(5) + 1,
          color: _getRandomColor(),
        ));
      }
    }
    
    _calculateBalance();
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

  void _calculateBalance() {
    int leftTotal = leftWeights.fold(0, (sum, weight) => sum + weight.value);
    int rightTotal = rightWeights.fold(0, (sum, weight) => sum + weight.value);
    
    double difference = (leftTotal - rightTotal).toDouble();
    targetAngle = (difference * 0.1).clamp(-0.5, 0.5);
    
    setState(() {
      seeSawAngle = targetAngle;
      isBalanced = difference.abs() <= 1;
    });
  }

  void _startBalanceCheck() {
    _balanceController.addListener(() {
      if (isBalanced) {
        setState(() {
          balanceTime += 0.1;
          if (balanceTime >= 3.0) {
            score += 10 * level;
            level++;
            balanceTime = 0.0;
            _generateWeights();
            _showLevelComplete();
          }
        });
      } else {
        setState(() {
          balanceTime = 0.0;
        });
      }
    });
    _balanceController.repeat();
  }

  void _showLevelComplete() {
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
                  Icons.emoji_events,
                  color: Colors.yellow,
                  size: 64,
                ),
                const SizedBox(height: 16),
                Text(
                  'Level $level Complete!',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'You balanced the seesaw!\nScore: $score',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff8654B0),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Continue'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _addWeight(bool isLeft) {
    setState(() {
      Weight newWeight = Weight(
        value: random.nextInt(3) + 1,
        color: _getRandomColor(),
      );
      
      if (isLeft) {
        leftWeights.add(newWeight);
      } else {
        rightWeights.add(newWeight);
      }
      
      _calculateBalance();
    });
  }

  void _removeWeight(bool isLeft, int index) {
    setState(() {
      if (isLeft && index < leftWeights.length) {
        leftWeights.removeAt(index);
      } else if (!isLeft && index < rightWeights.length) {
        rightWeights.removeAt(index);
      }
      
      _calculateBalance();
    });
  }

  void _resetGame() {
    setState(() {
      score = 0;
      level = 1;
      balanceTime = 0.0;
      _generateWeights();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff280446), // primaryD
      appBar: AppBar(
        backgroundColor: const Color(0xff18002D), // headerD
        title: const Text(
          'See Saw Balance',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
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
            // Score and Level Section
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                        'Level',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      Text(
                        '$level',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 1,
                    height: 35,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  Column(
                    children: [
                      const Text(
                        'Score',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      Text(
                        '$score',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 1,
                    height: 35,
                    color: Colors.white.withOpacity(0.3),
                  ),
                  Column(
                    children: [
                      Text(
                        isBalanced ? 'Balanced!' : 'Balancing...',
                        style: TextStyle(
                          color: isBalanced ? Colors.green : Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        width: 50,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: (balanceTime / 3.0).clamp(0.0, 1.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: isBalanced ? Colors.green : const Color(0xff8654B0),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Breathing Guide
            AnimatedBuilder(
              animation: _breathingAnimation,
              builder: (context, child) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Transform.scale(
                        scale: _breathingAnimation.value,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: const BoxDecoration(
                            color: Color(0xff8654B0),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Flexible(
                        child: Text(
                          'Breathe with the circle to stay calm',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 16),

            // See Saw Game Area
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Left weights
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Left side
                        Expanded(
                          child: Column(
                            children: [
                              Wrap(
                                children: leftWeights.asMap().entries.map((entry) {
                                  return GestureDetector(
                                    onTap: () => _removeWeight(true, entry.key),
                                    child: Container(
                                      margin: const EdgeInsets.all(2),
                                      width: 35,
                                      height: 35,
                                      decoration: BoxDecoration(
                                        color: entry.value.color,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${entry.value.value}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () => _addWeight(true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xff8654B0),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                                child: const Text(
                                  'Add Weight',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // See Saw
                        Column(
                          children: [
                            Transform.rotate(
                              angle: seeSawAngle,
                              child: Container(
                                width: 180,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: Colors.brown,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                            Container(
                              width: 20,
                              height: 35,
                              decoration: const BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(10),
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        // Right side
                        Expanded(
                          child: Column(
                            children: [
                              Wrap(
                                children: rightWeights.asMap().entries.map((entry) {
                                  return GestureDetector(
                                    onTap: () => _removeWeight(false, entry.key),
                                    child: Container(
                                      margin: const EdgeInsets.all(2),
                                      width: 35,
                                      height: 35,
                                      decoration: BoxDecoration(
                                        color: entry.value.color,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${entry.value.value}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () => _addWeight(false),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xff8654B0),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                                child: const Text(
                                  'Add Weight',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Instructions
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Balance the seesaw by adding or removing weights\nTap weights to remove them. Keep balanced for 3 seconds! ⚖️',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _balanceController.dispose();
    _breathingController.dispose();
    super.dispose();
  }
}

class Weight {
  final int value;
  final Color color;

  Weight({required this.value, required this.color});
}