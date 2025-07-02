import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TipsView extends StatefulWidget {
  const TipsView({super.key});

  @override
  State<TipsView> createState() => _TipsViewState();
}

class _TipsViewState extends State<TipsView> {
  int activeIndex = 0;

  final List<_TipsLink> tips = [
    _TipsLink(title: 'Body Shape Tips'),
    _TipsLink(title: 'Guilt After Eating Tips'),
    _TipsLink(title: 'Binge Eating Tips'),
    _TipsLink(title: 'Urge to Vomiting Tips'),
    _TipsLink(title: 'I\'m Failing Tips'),
    _TipsLink(title: 'General Tips'),
  ];

  final List<String> routes = [
    '/dashboard/help/eating-disorders/mindful-tips/body-shape',
    '/dashboard/help/eating-disorders/mindful-tips/guilt-after-eating',
    '/dashboard/help/eating-disorders/mindful-tips/binge-eating',
    '/dashboard/help/eating-disorders/mindful-tips/urge-to-vomiting',
    '/dashboard/help/eating-disorders/mindful-tips/im-failing',
    '/dashboard/help/eating-disorders/mindful-tips/general',
  ];

  @override
  Widget build(BuildContext context) {
    final bgColor = const Color(0xff491475);
    final activeColor = const Color(0xff4EA3AD);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: true,
        title: const Text('Tips Categories', style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 24, left: 20),
        child: Column(
          children: tips.asMap().entries.map((entry) {
            int idx = entry.key;
            _TipsLink tip = entry.value;
            bool isActive = idx == activeIndex;

            return GestureDetector(
              onTap: () {
                setState(() => activeIndex = idx);
                GoRouter.of(context).go(routes[idx]);
              },
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                decoration: BoxDecoration(
                  color: isActive ? activeColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isActive ? activeColor : Colors.white.withOpacity(0.3),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.tips_and_updates, color: Colors.white, size: 28),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Text(
                        tip.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _TipsLink {
  final String title;

  _TipsLink({required this.title});
}
