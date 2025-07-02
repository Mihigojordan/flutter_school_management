import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DepressionHelpPage extends StatefulWidget {
  const DepressionHelpPage({super.key});

  @override
  State<DepressionHelpPage> createState() => _DepressionHelpPageState();
}

class _DepressionHelpPageState extends State<DepressionHelpPage> {
  PageController _pageController = PageController();
  int _currentIndex = 0;

  List<DepressionTip> _tips = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    // Upload tips once then fetch them
    _uploadTipsAndFetch();
  }

  Future<void> _uploadTipsAndFetch() async {
    await uploadTips();
    await fetchTips();
  }

  Future<void> uploadTips() async {
    final tipsCollection = FirebaseFirestore.instance.collection('depression_tips');

    final tips = [
      {
        'title': "Start Small",
        'icon': "star_outline",
        'tip': "Begin with tiny, manageable tasks. Make your bed, brush your teeth, or drink a glass of water. Small wins build momentum.",
        'color': 0xff8654B0,
      },
      {
        'title': "Move Your Body",
        'icon': "directions_walk",
        'tip': "Even 5-10 minutes of movement helps. Take a short walk, stretch, or dance to one song. Movement releases mood-boosting chemicals.",
        'color': 0xff9B59B6,
      },
      {
        'title': "Connect Daily",
        'icon': "people_outline",
        'tip': "Reach out to one person daily. Send a text, make a call, or have a brief chat. Social connection combats isolation.",
        'color': 0xffAB47BC,
      },
      {
        'title': "Practice Gratitude",
        'icon': "favorite_outline",
        'tip': "Write down 3 small things you're grateful for each day. They can be tiny - a warm cup of coffee or a sunny moment.",
        'color': 0xffBA68C8,
      },
      {
        'title': "Establish Routine",
        'icon': "schedule",
        'tip': "Create a simple daily structure. Set regular sleep and meal times. Routine provides stability when emotions feel chaotic.",
        'color': 0xffCE93D8,
      },
      {
        'title': "Limit Social Media",
        'icon': "phone_android",
        'tip': "Reduce time comparing yourself to others online. Set specific times for social media or take breaks entirely.",
        'color': 0xff7B1FA2,
      },
      {
        'title': "Get Sunlight",
        'icon': "wb_sunny",
        'tip': "Spend 10-15 minutes in natural light daily. Open curtains, sit by a window, or step outside. Light helps regulate mood.",
        'color': 0xff8E24AA,
      },
      {
        'title': "Practice Self-Compassion",
        'icon': "self_improvement",
        'tip': "Talk to yourself like you would a good friend. Replace harsh self-criticism with gentle, understanding words.",
        'color': 0xff9C27B0,
      },
      {
        'title': "Focus on Breathing",
        'icon': "air",
        'tip': "Try the 4-7-8 technique: Inhale for 4, hold for 7, exhale for 8. Deep breathing activates your body's relaxation response.",
        'color': 0xffAD80B2,
      },
      {
        'title': "Seek Professional Help",
        'icon': "psychology",
        'tip': "Consider therapy or counseling. Professional support provides tools and strategies tailored to your specific needs.",
        'color': 0xff6A1B9A,
      },
    ];

    try {
      // Check if any tips exist already
      final existingTips = await tipsCollection.limit(1).get();

      if (existingTips.docs.isNotEmpty) {
        print("Tips already uploaded, skipping upload.");
        return; // Skip upload if tips already present
      }

      print("Uploading tips to Firestore...");

      for (final tip in tips) {
        await tipsCollection.add(tip);
        print('Uploaded tip: ${tip['title']}');
      }

      print("All tips uploaded successfully.");
    } catch (e) {
      print("Error uploading tips: $e");
    }
  }

  Future<void> fetchTips() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('depression_tips').get();

      final loadedTips = snapshot.docs.map((doc) {
        final data = doc.data();
        return DepressionTip(
          title: data['title'] ?? '',
          icon: iconFromString(data['icon'] ?? ''),
          tip: data['tip'] ?? '',
          color: Color(data['color'] ?? 0xff8654B0),
        );
      }).toList();

      setState(() {
        _tips = loadedTips;
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching tips: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  IconData iconFromString(String iconName) {
    switch (iconName) {
      case "star_outline":
        return Icons.star_outline;
      case "directions_walk":
        return Icons.directions_walk;
      case "people_outline":
        return Icons.people_outline;
      case "favorite_outline":
        return Icons.favorite_outline;
      case "schedule":
        return Icons.schedule;
      case "phone_android":
        return Icons.phone_android;
      case "wb_sunny":
        return Icons.wb_sunny;
      case "self_improvement":
        return Icons.self_improvement;
      case "air":
        return Icons.air;
      case "psychology":
        return Icons.psychology;
      default:
        return Icons.help_outline;
    }
  }

  void _nextTip() {
    if (_currentIndex < _tips.length - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  void _previousTip() {
    if (_currentIndex > 0) {
      _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff280446),
      appBar: AppBar(
        backgroundColor: const Color(0xff18002D),
        title: const Text(
          'Depression Support',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => GoRouter.of(context).go('/dashboard/home'),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  const SizedBox(height: 16),

                  // Progress Indicator
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${_currentIndex + 1} of ${_tips.length}',
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: (_currentIndex + 1) / _tips.length,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xff8654B0),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Tip Cards
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          _currentIndex = index;
                        });
                      },
                      itemCount: _tips.length,
                      itemBuilder: (context, index) {
                        final tip = _tips[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          child: Card(
                            color: const Color(0xff491475),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(color: tip.color.withOpacity(0.2), shape: BoxShape.circle),
                                    child: Icon(tip.icon, color: tip.color, size: 40),
                                  ),
                                  const SizedBox(height: 24),
                                  Text(
                                    tip.title,
                                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 20),
                                  Flexible(
                                    child: SingleChildScrollView(
                                      physics: const BouncingScrollPhysics(),
                                      child: Text(
                                        tip.tip,
                                        style: const TextStyle(color: Colors.white70, fontSize: 16, height: 1.6),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(color: tip.color.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                                    child: Text(
                                      'Tip ${index + 1}',
                                      style: TextStyle(color: tip.color, fontSize: 12, fontWeight: FontWeight.w600),
                                    ),
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
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _currentIndex > 0 ? _previousTip : null,
                          icon: const Icon(Icons.arrow_back, size: 14),
                          label: const Text('Prev', style: TextStyle(fontSize: 10)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _currentIndex > 0 ? const Color(0xff8654B0) : Colors.grey.withOpacity(0.3),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          ),
                        ),
                        Row(
                          children: List.generate(
                            _tips.length,
                            (index) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 1),
                              width: 4,
                              height: 4,
                              decoration: BoxDecoration(
                                color: _currentIndex == index ? const Color(0xff8654B0) : Colors.white.withOpacity(0.3),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: _currentIndex < _tips.length - 1 ? _nextTip : null,
                          icon: const Icon(Icons.arrow_forward, size: 14),
                          label: const Text('Next', style: TextStyle(fontSize: 10)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _currentIndex < _tips.length - 1 ? const Color(0xff8654B0) : Colors.grey.withOpacity(0.3),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Emergency Help Section
                  Container(
                    margin: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.red.withOpacity(0.3), width: 1),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.emergency, color: Colors.red[300], size: 12),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text('Crisis help: 988', style: TextStyle(color: Colors.red[300], fontSize: 9)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class DepressionTip {
  final String title;
  final IconData icon;
  final String tip;
  final Color color;

  DepressionTip({
    required this.title,
    required this.icon,
    required this.tip,
    required this.color,
  });
}
