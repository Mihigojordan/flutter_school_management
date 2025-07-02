import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:uuid/uuid.dart';

class SelfHarmTimerPage extends StatefulWidget {
  const SelfHarmTimerPage({super.key});

  @override
  State<SelfHarmTimerPage> createState() => _SelfHarmTimerPageState();
}

class _SelfHarmTimerPageState extends State<SelfHarmTimerPage> {
  Timer? _timer;
  int _seconds = 0;
  int _selectedDuration = 300; // 5 minutes default
  bool _isRunning = false;
  bool _isCompleted = false;
  
  final List<Map<String, dynamic>> _durations = [
    {'label': '1 min', 'seconds': 60},
    {'label': '3 min', 'seconds': 180},
    {'label': '5 min', 'seconds': 300},
    {'label': '10 min', 'seconds': 600},
    {'label': '15 min', 'seconds': 900},
    {'label': '20 min', 'seconds': 1200}, // Added 20 minute option
  ];

  final List<String> _encouragements = [
    "You're doing great! Keep going.",
    "Every second counts. You're stronger than you think.",
    "This feeling will pass. You're safe right now.",
    "Breathe deeply. You're in control.",
    "You're choosing yourself. That's brave.",
    "Almost there! You're handling this beautifully.",
    "Your strength is showing. Keep breathing.",
    "You matter. This moment will pass.",
  ];

  final List<String> _breathingInstructions = [
    "Breathe in slowly for 4 counts",
    "Hold your breath for 4 counts", 
    "Breathe out slowly for 6 counts",
    "Rest for 2 counts, then repeat",
  ];

  int _currentEncouragementIndex = 0;
  int _currentBreathingIndex = 0;
  
  // Firebase
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? _currentUser = FirebaseAuth.instance.currentUser;
  final Uuid _uuid = const Uuid();

  void _startTimer() {
    setState(() {
      _isRunning = true;
      _isCompleted = false;
      _seconds = _selectedDuration;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_seconds > 0) {
          _seconds--;
          // Change encouragement every 30 seconds
          if ((_selectedDuration - _seconds) % 30 == 0) {
            _currentEncouragementIndex = 
                (_currentEncouragementIndex + 1) % _encouragements.length;
          }
          // Change breathing instruction every 16 seconds (4+4+6+2)
          if ((_selectedDuration - _seconds) % 16 == 0) {
            _currentBreathingIndex = 
                (_currentBreathingIndex + 1) % _breathingInstructions.length;
          }
        } else {
          _timer?.cancel();
          _isRunning = false;
          _isCompleted = true;
          _saveTimerResult();
        }
      });
    });
  }

  Future<void> _saveTimerResult() async {
    if (_currentUser == null) return;
    
    try {
      await _firestore
          .collection('users')
          .doc(_currentUser!.uid)
          .collection('timer_results')
          .add({
            'duration': _selectedDuration,
            'completed_at': Timestamp.now(),
            'uuid': _uuid.v4(),
          });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving timer result: ${e.toString()}')),
      );
    }
  }

  Future<void> _rememberThisMoment() async {
    if (_currentUser == null) return;
    
    try {
      await _firestore
          .collection('users')
          .doc(_currentUser!.uid)
          .collection('remembered_moments')
          .add({
            'timestamp': Timestamp.now(),
            'uuid': _uuid.v4(),
            'duration': _selectedDuration,
            'note': 'Successfully completed ${_selectedDuration ~/ 60} minute timer',
          });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Moment remembered successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error remembering moment: ${e.toString()}')),
      );
    }
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _isCompleted = false;
      _seconds = 0;
      _currentEncouragementIndex = 0;
      _currentBreathingIndex = 0;
    });
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  double _getProgress() {
    if (_selectedDuration == 0) return 0;
    return (_selectedDuration - _seconds) / _selectedDuration;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff280446),
      appBar: AppBar(
        backgroundColor: const Color(0xff18002D),
        title: const Text(
          'Urge Timer',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => GoRouter.of(context).go('/dashboard/help/self-harm'),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Header
                Container(
                  margin: const EdgeInsets.only(bottom: 20), // Added margin bottom
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xff491475),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        color: Colors.white,
                        size: 32,
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Wait It Out',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Urges are temporary. Let\'s get through this together.',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                if (!_isRunning && !_isCompleted) ...[
                  // Duration Selection
                  const Text(
                    'How long would you like to wait?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12, // Added runSpacing for better wrapping
                    children: _durations.map((duration) {
                      final isSelected = _selectedDuration == duration['seconds'];
                      return GestureDetector(
                        onTap: () => setState(() => _selectedDuration = duration['seconds']),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xff4CAF50) : const Color(0xff491475),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? const Color(0xff4CAF50) : Colors.white.withOpacity(0.1),
                              width: 2,
                            ),
                          ),
                          child: Text(
                            duration['label'],
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 30),
                  
                  // Start Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _startTimer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff4CAF50),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Start Timer (${_durations.firstWhere((d) => d['seconds'] == _selectedDuration)['label']})',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],

                if (_isRunning) ...[
                  // Timer Display
                  Column(
                    children: [
                      // Progress Circle
                      SizedBox(
                        width: 200,
                        height: 200,
                        child: Stack(
                          children: [
                            Center(
                              child: SizedBox(
                                width: 200,
                                height: 200,
                                child: CircularProgressIndicator(
                                  value: _getProgress(),
                                  strokeWidth: 8,
                                  backgroundColor: Colors.white.withOpacity(0.2),
                                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xff4CAF50)),
                                ),
                              ),
                            ),
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _formatTime(_seconds),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${((_getProgress()) * 100).round()}% Complete',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      
                      // Encouragement
                      Container(
                        margin: const EdgeInsets.only(bottom: 20), // Added margin bottom
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xff491475),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.favorite,
                              color: Color(0xff4CAF50),
                              size: 24,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _encouragements[_currentEncouragementIndex],
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Breathing Guide
                      Container(
                        margin: const EdgeInsets.only(bottom: 20), // Added margin bottom
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xff2196F3).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xff2196F3),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Breathing Exercise',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _breathingInstructions[_currentBreathingIndex],
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  // Control Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _pauseTimer,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xffFF9800),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Pause',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _resetTimer,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xffF44336),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Reset',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],

                if (_isCompleted) ...[
                  // Completion Screen
                  Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 20), // Added margin bottom
                        padding: const EdgeInsets.all(40),
                        decoration: BoxDecoration(
                          color: const Color(0xff4CAF50),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 60,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(bottom: 20), // Added margin bottom
                        child: const Text(
                          'You Did It! 🎉',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(bottom: 20), // Added margin bottom
                        child: const Text(
                          'You successfully waited out the urge. That took real strength and courage.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      
                      Container(
                        margin: const EdgeInsets.only(bottom: 20), // Added margin bottom
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xff491475),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            const Text(
                              'Remember This Moment',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'You proved to yourself that urges pass. You have the strength to get through difficult moments.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _rememberThisMoment,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xff4CAF50),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Save This Achievement',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  
                  // New Timer Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _resetTimer,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff4CAF50),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Start New Timer',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 20), // Added bottom padding to prevent overflow
              ],
            ),
          ),
        ),
      ),
    );
  }
}