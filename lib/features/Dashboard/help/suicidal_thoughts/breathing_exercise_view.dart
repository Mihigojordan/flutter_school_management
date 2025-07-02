// features/Dashboard/help/suicidal_thoughts/breathing_exercise_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

class BreathingExerciseView extends ConsumerStatefulWidget {
  const BreathingExerciseView({super.key});

  @override
  ConsumerState<BreathingExerciseView> createState() => _BreathingExerciseViewState();
}

class _BreathingExerciseViewState extends ConsumerState<BreathingExerciseView>
    with TickerProviderStateMixin {
  late AnimationController _breathingController;
  late Animation<double> _breathingAnimation;
  Timer? _timer;
  
  bool _isRunning = false;
  int _currentPhase = 0; // 0: inhale, 1: hold, 2: exhale, 3: hold
  int _remainingTime = 4;
  int _totalCycles = 0;
  
  final List<String> _phases = ['Inhale', 'Hold', 'Exhale', 'Hold'];
  final List<int> _phaseDurations = [4, 4, 4, 4]; // 4-4-4-4 breathing
  final List<Color> _phaseColors = [
    const Color(0xFF3498DB), // Blue for inhale
    const Color(0xFFF39C12), // Orange for hold
    const Color(0xFF2ECC71), // Green for exhale
    const Color(0xFF9B59B6), // Purple for hold
  ];

  @override
  void initState() {
    super.initState();
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
  }

  @override
  void dispose() {
    _breathingController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startExercise() {
    if (_isRunning) {
      _stopExercise();
      return;
    }
    
    setState(() {
      _isRunning = true;
      _currentPhase = 0;
      _remainingTime = _phaseDurations[_currentPhase];
    });
    
    _runPhase();
  }

  void _stopExercise() {
    _timer?.cancel();
    _breathingController.reset();
    
    setState(() {
      _isRunning = false;
      _currentPhase = 0;
      _remainingTime = 4;
    });
  }

  void _runPhase() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _remainingTime--;
      });
      
      if (_remainingTime <= 0) {
        _nextPhase();
      }
    });
    
    // Animate breathing circle
    if (_currentPhase == 0) { // Inhale
      _breathingController.forward();
    } else if (_currentPhase == 2) { // Exhale
      _breathingController.reverse();
    }
  }

  void _nextPhase() {
    _timer?.cancel();
    
    setState(() {
      _currentPhase = (_currentPhase + 1) % 4;
      _remainingTime = _phaseDurations[_currentPhase];
      
      if (_currentPhase == 0) {
        _totalCycles++;
      }
    });
    
    if (_isRunning) {
      _runPhase();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      appBar: AppBar(
        title: const Text('Breathing Exercise'),
        backgroundColor: const Color(0xFF1a1a2e),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard/help/suicidal-thoughts'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF3498DB).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF3498DB).withOpacity(0.3)),
              ),
              child: const Column(
                children: [
                  Icon(Icons.air, color: Color(0xFF3498DB), size: 32),
                  SizedBox(height: 12),
                  Text(
                    '4-4-4-4 Breathing',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'This breathing technique can help reduce anxiety and promote relaxation.',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Breathing Circle
            AnimatedBuilder(
              animation: _breathingAnimation,
              builder: (context, child) {
                return Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _phaseColors[_currentPhase].withOpacity(0.3),
                    border: Border.all(
                      color: _phaseColors[_currentPhase],
                      width: 3,
                    ),
                  ),
                  transform: Matrix4.identity()
                    ..scale(_breathingAnimation.value),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _phases[_currentPhase],
                          style: TextStyle(
                            color: _phaseColors[_currentPhase],
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$_remainingTime',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 40),
            
            // Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatCard('Cycles', '$_totalCycles', Icons.refresh),
                _buildStatCard('Phase', _phases[_currentPhase], Icons.timeline),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Control Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _startExercise,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isRunning ? const Color(0xFFE74C3C) : const Color(0xFF2ECC71),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _isRunning ? 'Stop Exercise' : 'Start Exercise',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Instructions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF2D2D42),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'How to Practice:',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• Sit comfortably with your back straight\n'
                    '• Close your eyes or focus on the circle\n'
                    '• Follow the breathing pattern shown\n'
                    '• Try to practice for 5-10 minutes daily',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D42),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF3498DB), size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}