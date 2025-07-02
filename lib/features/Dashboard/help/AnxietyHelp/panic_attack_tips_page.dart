import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PanicAttackTipsPage extends StatefulWidget {
  const PanicAttackTipsPage({super.key});

  @override
  State<PanicAttackTipsPage> createState() => _PanicAttackTipsPageState();
}

class _PanicAttackTipsPageState extends State<PanicAttackTipsPage> {
  int currentTipIndex = 0;
  final PageController pageController = PageController();
  List<Tip> panicAttackTips = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _uploadDefaultPanicTips().then((_) => _fetchTipsFromFirestore());
  }

  Future<void> _uploadDefaultPanicTips() async {
    final collection = FirebaseFirestore.instance.collection('panic_attack_tips');
    final existing = await collection.limit(1).get();
    if (existing.docs.isNotEmpty) return;

    final defaultTips = [
      {
        'order': 1,
        'title': 'Ground Yourself with 5-4-3-2-1',
        'description':
            'Name 5 things you can see, 4 things you can touch, 3 things you can hear, 2 things you can smell, and 1 thing you can taste.',
        'icon_code': Icons.visibility_outlined.codePoint,
        'color': 0xff8654B0,
      },
      {
        'order': 2,
        'title': 'Deep Breathing Technique',
        'description':
            'Breathe in slowly through your nose for 4 counts, hold for 4 counts, then breathe out through your mouth for 6 counts.',
        'icon_code': Icons.air_outlined.codePoint,
        'color': 0xff9B59B6,
      },
      {
        'order': 3,
        'title': 'Progressive Muscle Relaxation',
        'description':
            'Tense and then relax each muscle group in your body, starting from your toes and working up to your head.',
        'icon_code': Icons.self_improvement_outlined.codePoint,
        'color': 0xffAB47BC,
      },
      {
        'order': 4,
        'title': 'Accept the Feeling',
        'description':
            'Remind yourself: "This is a panic attack. It will pass. I am not in danger. This feeling is temporary."',
        'icon_code': Icons.favorite_outline.codePoint,
        'color': 0xffBA68C8,
      },
      {
        'order': 5,
        'title': 'Focus on Your Breath',
        'description':
            'Place one hand on your chest and one on your belly. Focus on making the hand on your belly rise more than the one on your chest.',
        'icon_code': Icons.scatter_plot_outlined.codePoint,
        'color': 0xffCE93D8,
      },
      {
        'order': 6,
        'title': 'Use Cold Water',
        'description':
            'Splash cold water on your face, hold ice cubes, or drink cold water to activate your body\'s dive response and calm your nervous system.',
        'icon_code': Icons.water_drop_outlined.codePoint,
        'color': 0xff7B1FA2,
      },
      {
        'order': 7,
        'title': 'Challenge Negative Thoughts',
        'description':
            'Ask yourself: "Is this thought realistic? What would I tell a friend in this situation? What\'s the worst that could really happen?"',
        'icon_code': Icons.psychology_outlined.codePoint,
        'color': 0xff6A1B9A,
      },
      {
        'order': 8,
        'title': 'Create a Safe Space',
        'description':
            'Find a quiet, comfortable place. Sit or lie down. Close your eyes and imagine yourself in a peaceful, safe location.',
        'icon_code': Icons.home_outlined.codePoint,
        'color': 0xff4A148C,
      },
    ];

    for (var tip in defaultTips) {
      await collection.add(tip);
    }
  }

  Future<void> _fetchTipsFromFirestore() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('panic_attack_tips')
          .orderBy('order')
          .get();

      final tips = snapshot.docs.map((doc) {
        final data = doc.data();
        return Tip(
          title: data['title'] ?? '',
          description: data['description'] ?? '',
          icon: IconData(data['icon_code'], fontFamily: 'MaterialIcons'),
          color: Color(data['color'] ?? 0xff8654B0),
        );
      }).toList();

      setState(() {
        panicAttackTips = tips;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching panic tips: $e');
      setState(() => _isLoading = false);
    }
  }

  void nextTip() {
    if (currentTipIndex < panicAttackTips.length - 1) {
      setState(() => currentTipIndex++);
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void previousTip() {
    if (currentTipIndex > 0) {
      setState(() => currentTipIndex--);
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff280446),
      appBar: AppBar(
        backgroundColor: const Color(0xff18002D),
        title: const Text(
          'Panic Attack Tips',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => GoRouter.of(context).go('/dashboard/help/anxiety'),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Tip ${currentTipIndex + 1} of ${panicAttackTips.length}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xff491475),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Swipe to navigate →',
                                style: TextStyle(color: Colors.white70, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        LinearProgressIndicator(
                          value: (currentTipIndex + 1) / panicAttackTips.length,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xff8654B0)),
                          minHeight: 4,
                        ),
                      ],
                    ),
                  ),

                  // Tip Card
                  Expanded(
                    child: PageView.builder(
                      controller: pageController,
                      itemCount: panicAttackTips.length,
                      onPageChanged: (i) => setState(() => currentTipIndex = i),
                      itemBuilder: (context, i) {
                        final tip = panicAttackTips[i];
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: const Color(0xff491475),
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: tip.color,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      tip.icon,
                                      color: Colors.white,
                                      size: 32,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Text(
                                    tip.title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    tip.description,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 16,
                                      height: 1.5,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  // Navigation Buttons
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton.icon(
                          onPressed: currentTipIndex > 0 ? previousTip : null,
                          icon: const Icon(Icons.arrow_back_ios, size: 16),
                          label: const Text('Previous'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff8654B0),
                            disabledBackgroundColor: Colors.grey.withOpacity(0.3),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        Row(
                          children: List.generate(
                            panicAttackTips.length,
                            (i) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: currentTipIndex == i
                                    ? const Color(0xff8654B0)
                                    : Colors.white.withOpacity(0.3),
                              ),
                            ),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: currentTipIndex < panicAttackTips.length - 1 ? nextTip : null,
                          icon: const Icon(Icons.arrow_forward_ios, size: 16),
                          label: const Text('Next'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff8654B0),
                            disabledBackgroundColor: Colors.grey.withOpacity(0.3),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class Tip {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  Tip({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
