import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:math';

class ArithmeticExercisePage extends StatefulWidget {
  const ArithmeticExercisePage({super.key});

  @override
  State<ArithmeticExercisePage> createState() => _ArithmeticExercisePageState();
}

class _ArithmeticExercisePageState extends State<ArithmeticExercisePage> {
  int num1 = 0;
  int num2 = 0;
  int correctAnswer = 0;
  int userAnswer = 0;
  int score = 0;
  int questionsAnswered = 0;
  String operation = '+';
  List<int> options = [];
  int? selectedOption;
  bool showResult = false;
  bool isCorrect = false;
  
  final Random random = Random();

  @override
  void initState() {
    super.initState();
    generateQuestion();
  }

  void generateQuestion() {
    setState(() {
      showResult = false;
      selectedOption = null;
      
      // Randomly choose operation
      List<String> operations = ['+', '-', '×'];
      operation = operations[random.nextInt(operations.length)];
      
      switch (operation) {
        case '+':
          num1 = random.nextInt(50) + 1;
          num2 = random.nextInt(50) + 1;
          correctAnswer = num1 + num2;
          break;
        case '-':
          num1 = random.nextInt(50) + 25;
          num2 = random.nextInt(num1);
          correctAnswer = num1 - num2;
          break;
        case '×':
          num1 = random.nextInt(12) + 1;
          num2 = random.nextInt(12) + 1;
          correctAnswer = num1 * num2;
          break;
      }
      
      // Generate options
      options = [correctAnswer];
      while (options.length < 4) {
        int wrongAnswer;
        if (operation == '×') {
          wrongAnswer = correctAnswer + random.nextInt(20) - 10;
        } else {
          wrongAnswer = correctAnswer + random.nextInt(40) - 20;
        }
        
        if (!options.contains(wrongAnswer) && wrongAnswer > 0) {
          options.add(wrongAnswer);
        }
      }
      options.shuffle();
    });
  }

  void selectAnswer(int answer) {
    setState(() {
      selectedOption = answer;
      userAnswer = answer;
      isCorrect = answer == correctAnswer;
      showResult = true;
      
      if (isCorrect) {
        score++;
      }
      questionsAnswered++;
    });
    
    // Auto-advance after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        generateQuestion();
      }
    });
  }

  void resetGame() {
    setState(() {
      score = 0;
      questionsAnswered = 0;
      generateQuestion();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff280446), // primaryD
      appBar: AppBar(
        backgroundColor: const Color(0xff18002D), // headerD
        title: const Text(
          'Arithmetic Exercise',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => GoRouter.of(context).go('/dashboard/help/anxiety'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: resetGame,
          ),
        ],
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Score Section
              Container(
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
                          'Questions',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        Text(
                          '$questionsAnswered',
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
                          'Accuracy',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        Text(
                          questionsAnswered > 0 
                              ? '${((score / questionsAnswered) * 100).round()}%'
                              : '0%',
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
              
              const SizedBox(height: 40),
              
              // Question Section
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: const Color(0xff491475), // containerD
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'What is the answer?',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$num1',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xff8654B0), // dropdownMenuD
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            operation,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Text(
                          '$num2',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    if (showResult) ...[
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isCorrect ? Colors.green : Colors.red,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isCorrect ? 'Correct! 🎉' : 'Correct answer: $correctAnswer',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Options Section
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.5,
                  children: options.map((option) {
                    bool isSelected = selectedOption == option;
                    bool isCorrectAnswer = option == correctAnswer;
                    
                    Color backgroundColor;
                    if (showResult && isSelected) {
                      backgroundColor = isCorrectAnswer ? Colors.green : Colors.red;
                    } else if (showResult && isCorrectAnswer) {
                      backgroundColor = Colors.green;
                    } else {
                      backgroundColor = const Color(0xff491475); // containerD
                    }
                    
                    return GestureDetector(
                      onTap: showResult ? null : () => selectAnswer(option),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: backgroundColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected 
                                ? Colors.white 
                                : Colors.white.withOpacity(0.2),
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            '$option',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              
              // Motivational Text
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Focus on the math to calm your mind 🧠\nTake your time, there\'s no rush!',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}