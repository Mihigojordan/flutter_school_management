import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BodyShapeTipsPage extends StatefulWidget {
  const BodyShapeTipsPage({super.key});

  @override
  State<BodyShapeTipsPage> createState() => _BodyShapeTipsPageState();
}

class _BodyShapeTipsPageState extends State<BodyShapeTipsPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  List<Tip> _tips = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeTips();
    _getTips();
  }

  Future<void> _initializeTips() async {
    final collection = FirebaseFirestore.instance.collection('body_shape_tips');
    final snapshot = await collection.get();

    if (snapshot.docs.isEmpty) {
      // Add default body shape tips if collection is empty
      await collection.add({
        'title': 'Dress for Your Shape',
        'content': 'Choose clothes that accentuate your best features and balance proportions.',
        'category': 'body_shape'
      });
      
      await collection.add({
        'title': 'Posture Matters',
        'content': 'Good posture instantly improves your silhouette and makes clothes fit better.',
        'category': 'body_shape'
      });
      
      await collection.add({
        'title': 'Targeted Exercises',
        'content': 'Focus on exercises that enhance your natural body proportions.',
        'category': 'body_shape'
      });
    }
  }

  Future<void> _getTips() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('body_shape_tips')
        .where('category', isEqualTo: 'body_shape')
        .get();

    setState(() {
      _tips = snapshot.docs.map((doc) => Tip.fromMap(doc.data())).toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Body Shape Tips'),
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
                                  _tips[index].title,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  _tips[index].content,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.white70,
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

class Tip {
  final String title;
  final String content;
  final String category;

  Tip({
    required this.title,
    required this.content,
    required this.category,
  });

  factory Tip.fromMap(Map<String, dynamic> map) {
    return Tip(
      title: map['title'] ?? '',
      content: map['content'] ?? '',
      category: map['category'] ?? '',
    );
  }
}