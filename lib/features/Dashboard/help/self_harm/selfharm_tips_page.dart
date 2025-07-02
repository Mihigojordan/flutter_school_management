import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SelfHarmTipsPage extends StatefulWidget {
  const SelfHarmTipsPage({super.key});

  @override
  State<SelfHarmTipsPage> createState() => _SelfHarmTipsPageState();
}

class _SelfHarmTipsPageState extends State<SelfHarmTipsPage> {
  List<CopingStrategy> copingStrategies = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _uploadAndFetchStrategies();
  }

  Future<void> _uploadAndFetchStrategies() async {
    await _uploadDefaultStrategies();
    await _fetchStrategies();
  }

  Future<void> _uploadDefaultStrategies() async {
    final collection = FirebaseFirestore.instance.collection('self_harm_coping_strategies');

    try {
      final existing = await collection.limit(1).get();
      if (existing.docs.isNotEmpty) return;

      final defaultStrategies = [
        {
          'category': 'Physical Alternatives',
          'tips': [
            'Hold ice cubes in your hands',
            'Take a cold shower',
            'Do intense exercise (push-ups, running)',
            'Squeeze a stress ball or punch a pillow',
            'Draw on your skin with a red marker',
          ],
          'icon': 'fitness_center_outlined',
          'color': 0xff4CAF50,
        },
        {
          'category': 'Emotional Release',
          'tips': [
            'Scream into a pillow',
            'Tear up paper or magazines',
            'Write angry letters (don\'t send them)',
            'Listen to music that matches your mood',
            'Cry - it\'s okay to let it out',
          ],
          'icon': 'psychology_outlined',
          'color': 0xff2196F3,
        },
        {
          'category': 'Distraction Techniques',
          'tips': [
            'Call a friend or family member',
            'Watch funny videos or movies',
            'Play games on your phone',
            'Do a puzzle or crossword',
            'Clean or organize something',
          ],
          'icon': 'extension_outlined',
          'color': 0xffFF9800,
        },
        {
          'category': 'Self-Care Activities',
          'tips': [
            'Take a warm bath with candles',
            'Do your skincare routine',
            'Make your favorite snack',
            'Practice deep breathing',
            'Give yourself a massage',
          ],
          'icon': 'spa_outlined',
          'color': 0xff9C27B0,
        },
      ];

      for (final strategy in defaultStrategies) {
        await collection.add(strategy);
      }
    } catch (e) {
      print("Error uploading coping strategies: $e");
    }
  }

  Future<void> _fetchStrategies() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('self_harm_coping_strategies').get();

      final loadedStrategies = snapshot.docs.map((doc) {
        final data = doc.data();
        return CopingStrategy(
          category: data['category'] ?? '',
          tips: List<String>.from(data['tips'] ?? []),
          icon: _iconFromString(data['icon'] ?? ''),
          color: Color(data['color'] ?? 0xff4CAF50),
        );
      }).toList();

      setState(() {
        copingStrategies = loadedStrategies;
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching coping strategies: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  IconData _iconFromString(String iconName) {
    switch (iconName) {
      case 'fitness_center_outlined':
        return Icons.fitness_center_outlined;
      case 'psychology_outlined':
        return Icons.psychology_outlined;
      case 'extension_outlined':
        return Icons.extension_outlined;
      case 'spa_outlined':
        return Icons.spa_outlined;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff280446),
      appBar: AppBar(
        backgroundColor: const Color(0xff18002D),
        title: const Text(
          'Coping Tips',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => GoRouter.of(context).go('/dashboard/help/self-harm'),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xff491475),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.lightbulb_outline, color: Colors.white, size: 32),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Healthy Alternatives',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Try these instead when you feel the urge',
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

                    // Strategies List
                    Expanded(
                      child: ListView.builder(
                        itemCount: copingStrategies.length,
                        itemBuilder: (context, index) {
                          final strategy = copingStrategies[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xff491475),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.1),
                                width: 1,
                              ),
                            ),
                            child: ExpansionTile(
                              title: Text(
                                strategy.category,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              iconColor: Colors.white70,
                              collapsedIconColor: Colors.white70,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: strategy.tips.length,
                                    itemBuilder: (context, tipIndex) {
                                      return Container(
                                        margin: const EdgeInsets.only(bottom: 8),
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.05),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          strategy.tips[tipIndex],
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 14,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                    // Bottom Reminder
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xff4CAF50).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xff4CAF50),
                          width: 1,
                        ),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.favorite, color: Color(0xff4CAF50), size: 20),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Remember: You deserve care and kindness, especially from yourself',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

class CopingStrategy {
  final String category;
  final List<String> tips;
  final IconData icon;
  final Color color;

  CopingStrategy({
    required this.category,
    required this.tips,
    required this.icon,
    required this.color,
  });
}
