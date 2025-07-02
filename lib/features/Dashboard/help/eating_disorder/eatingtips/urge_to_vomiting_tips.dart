import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UrgeToVomitingTipsPage extends StatefulWidget {
  const UrgeToVomitingTipsPage({super.key});

  @override
  State<UrgeToVomitingTipsPage> createState() => _UrgeToVomitingTipsPageState();
}

class _UrgeToVomitingTipsPageState extends State<UrgeToVomitingTipsPage> {
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
        .collection('vomiting_tips')
        .get();

    if (snapshot.docs.isEmpty) {
      await FirebaseFirestore.instance.collection('vomiting_tips').add({
        'title': 'Delay Tactics',
        'content': 'Wait 15 minutes - the urge often passes',
      });
      await FirebaseFirestore.instance.collection('vomiting_tips').add({
        'title': 'Distract Yourself',
        'content': 'Call a friend or go for a walk',
      });
      await FirebaseFirestore.instance.collection('vomiting_tips').add({
        'title': 'Remember the Consequences',
        'content': 'Vomiting harms your teeth, throat and overall health',
      });
    }

    _loadTips();
  }

  Future<void> _loadTips() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('vomiting_tips')
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
        title: const Text('Urge to Vomiting Tips'),
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