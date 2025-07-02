import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GuiltAfterEatingTipsPage extends StatefulWidget {
  const GuiltAfterEatingTipsPage({super.key});

  @override
  State<GuiltAfterEatingTipsPage> createState() => _GuiltAfterEatingTipsPageState();
}

class _GuiltAfterEatingTipsPageState extends State<GuiltAfterEatingTipsPage> {
  final PageController _pageController = PageController();
  List<Map<String, String>> _tips = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeTips();
  }

  Future<void> _initializeTips() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('guilt_tips')
        .get();

    if (snapshot.docs.isEmpty) {
      await FirebaseFirestore.instance.collection('guilt_tips').add({
        'title': 'Practice Self-Compassion',
        'content': 'Remember that one meal doesn\'t define your health journey',
      });
      await FirebaseFirestore.instance.collection('guilt_tips').add({
        'title': 'Reframe Your Thoughts',
        'content': 'Instead of "I cheated", think "I enjoyed a treat"',
      });
      await FirebaseFirestore.instance.collection('guilt_tips').add({
        'title': 'Mindfulness Techniques',
        'content': 'Try deep breathing when guilt feelings arise',
      });
    }

    _loadTips();
  }

  Future<void> _loadTips() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('guilt_tips')
        .get();

    setState(() {
      _tips = snapshot.docs.map((doc) => doc.data() as Map<String, String>).toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guilt After Eating Tips'),
        backgroundColor: const Color(0xff18002D),
      ),
      backgroundColor: const Color(0xff280446),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _tips.length,
                    onPageChanged: (index) {
                      setState(() {
                      });
                    },
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xff491475),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _tips[index]['title']!,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  _tips[index]['content']!,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.white70,
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
                // Navigation controls same as above...
              ],
            ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}