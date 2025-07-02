import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GeneralTipsPage extends StatefulWidget {
  const GeneralTipsPage({super.key});

  @override
  State<GeneralTipsPage> createState() => _GeneralTipsPageState();
}

class _GeneralTipsPageState extends State<GeneralTipsPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  List<Map<String, String>> _tips = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeTips();
  }

  Future<void> _initializeTips() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('general_tips')
        .get();

    if (snapshot.docs.isEmpty) {
      await FirebaseFirestore.instance.collection('general_tips').add({
        'title': 'Stay Hydrated',
        'content': 'Drink at least 8 glasses of water daily for optimal health',
      });
      await FirebaseFirestore.instance.collection('general_tips').add({
        'title': 'Regular Exercise',
        'content': 'Aim for 30 minutes of moderate activity most days',
      });
      await FirebaseFirestore.instance.collection('general_tips').add({
        'title': 'Balanced Diet',
        'content': 'Include fruits, vegetables, proteins and whole grains',
      });
    }

    _loadTips();
  }

  Future<void> _loadTips() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('general_tips')
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
        title: const Text('General Tips'),
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
                        _currentPage = index;
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
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: _currentPage > 0
                            ? () {
                                _pageController.previousPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              }
                            : null,
                      ),
                      ...List.generate(
                        _tips.length,
                        (index) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentPage == index
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.4),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward, color: Colors.white),
                        onPressed: _currentPage < _tips.length - 1
                            ? () {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              }
                            : null,
                      ),
                    ],
                  ),
                ),
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