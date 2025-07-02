import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ImFailingTipsPage extends StatefulWidget {
  const ImFailingTipsPage({super.key});

  @override
  State<ImFailingTipsPage> createState() => _ImFailingTipsPageState();
}

class _ImFailingTipsPageState extends State<ImFailingTipsPage> {
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
        .collection('failing_tips')
        .get();

    if (snapshot.docs.isEmpty) {
      await FirebaseFirestore.instance.collection('failing_tips').add({
        'title': 'Progress Isn\'t Linear',
        'content': 'Everyone has setbacks - what matters is getting back up',
      });
      await FirebaseFirestore.instance.collection('failing_tips').add({
        'title': 'Small Steps Count',
        'content': 'Focus on one small positive change at a time',
      });
      await FirebaseFirestore.instance.collection('failing_tips').add({
        'title': 'Reassess Your Goals',
        'content': 'Maybe your expectations need adjustment',
      });
    }

    _loadTips();
  }

  Future<void> _loadTips() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('failing_tips')
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
        title: const Text('I\'m Failing Tips'),
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