import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class AppColors {
  static const primaryD = Color(0xff280446);
  static const containerD = Color(0xff491475);
  static const headerD = Color(0xff18002D);
  static const dropdownMenuD = Color(0xff8654B0);
}

class HealthBlogPage extends StatefulWidget {
  const HealthBlogPage({super.key});

  @override
  State<HealthBlogPage> createState() => _HealthBlogPageState();
}

class _HealthBlogPageState extends State<HealthBlogPage> {
  final TextEditingController _searchController = TextEditingController();
  final FlutterTts _flutterTts = FlutterTts();
  late stt.SpeechToText _speech;
  bool _isListening = false;

  List<DocumentSnapshot> _blogs = [];
  List<DocumentSnapshot> _filteredBlogs = [];

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _loadBlogsFromFirebase();

    // Listen to typing and filter blogs dynamically
    _searchController.addListener(() {
      _filterBlogs(_searchController.text);
      setState(() {}); // To update suffixIcon visibility
    });
  }

  Future<void> _loadBlogsFromFirebase() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('blogs')
          .orderBy('timestamp', descending: true)
          .limit(50)
          .get();

      setState(() {
        _blogs = snapshot.docs;
        _filteredBlogs = _blogs;
      });
    } catch (e) {
      print("Error loading blogs: $e");
    }
  }

  void _filterBlogs(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredBlogs = _blogs;
      });
      return;
    }

    final filtered = _blogs.where((doc) {
      final title = doc['title']?.toString().toLowerCase() ?? '';
      final content = doc['content']?.toString().toLowerCase() ?? '';
      return title.contains(query.toLowerCase()) || content.contains(query.toLowerCase());
    }).toList();

    setState(() {
      _filteredBlogs = filtered;
    });
  }

  Future<void> _speak(String text) async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.speak(text);
  }

  void _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (val) {
          if (val == 'done') setState(() => _isListening = false);
        },
        onError: (val) => print('Speech error: $val'),
      );
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) {
            _searchController.text = val.recognizedWords;
            _searchController.selection = TextSelection.fromPosition(
              TextPosition(offset: _searchController.text.length),
            );
            _filterBlogs(val.recognizedWords);
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _speech.stop();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryD,
      appBar: AppBar(
        backgroundColor: AppColors.headerD,
        title: const Text(
          'Health Voice Blog',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(_isListening ? Icons.mic_off : Icons.mic),
            onPressed: _listen,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search blogs...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _filterBlogs('');
                          FocusScope.of(context).unfocus(); // Hide keyboard
                        },
                      ),
                filled: true,
                fillColor: AppColors.dropdownMenuD.withOpacity(0.1),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.dropdownMenuD),
                  borderRadius: BorderRadius.circular(10),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          Expanded(
            child: _filteredBlogs.isEmpty
                ? const Center(
                    child: Text('No blogs found', style: TextStyle(color: Colors.white70)),
                  )
                : ListView.builder(
                    itemCount: _filteredBlogs.length,
                    itemBuilder: (context, index) {
                      final blog = _filteredBlogs[index];
                      final title = blog['title'] ?? 'No Title';
                      final content = blog['content'] ?? '';

                      return Card(
                        color: AppColors.containerD,
                        margin: const EdgeInsets.all(8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          title: Text(title, style: const TextStyle(color: Colors.white)),
                          subtitle: Text(
                            content.length > 60 ? content.substring(0, 60) + '...' : content,
                            style: const TextStyle(color: Colors.white70),
                          ),
                          trailing: PopupMenuButton(
                            iconColor: Colors.white,
                            itemBuilder: (_) => [
                              const PopupMenuItem(value: 'read', child: Text('Read')),
                              const PopupMenuItem(value: 'listen', child: Text('Listen')),
                            ],
                            onSelected: (value) {
                              if (value == 'read') {
                                showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    backgroundColor: AppColors.headerD,
                                    title: Text(title, style: const TextStyle(color: Colors.white)),
                                    content: SingleChildScrollView(
                                      child: Text(content, style: const TextStyle(color: Colors.white70)),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Close', style: TextStyle(color: Colors.white)),
                                      )
                                    ],
                                  ),
                                );
                              } else if (value == 'listen') {
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (_) => AlertDialog(
                                    backgroundColor: AppColors.headerD,
                                    title: Text(title, style: const TextStyle(color: Colors.white)),
                                    content: SingleChildScrollView(
                                      child: _SpeakingContent(
                                        text: content,
                                        flutterTts: _flutterTts,
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () async {
                                          await _flutterTts.stop();
                                          Navigator.pop(context);
                                        },
                                        child: const Text('Stop', style: TextStyle(color: Colors.white)),
                                      )
                                    ],
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/// Widget that highlights spoken text during TTS reading
class _SpeakingContent extends StatefulWidget {
  final String text;
  final FlutterTts flutterTts;

  const _SpeakingContent({required this.text, required this.flutterTts, Key? key}) : super(key: key);

  @override
  State<_SpeakingContent> createState() => _SpeakingContentState();
}

class _SpeakingContentState extends State<_SpeakingContent> {
  int _currentWordIndex = -1;
  late List<String> _words;

  @override
  void initState() {
    super.initState();
    _words = widget.text.split(RegExp(r'\s+'));

    widget.flutterTts.setProgressHandler((String text, int start, int end, String word) {
      setState(() {
        _currentWordIndex = _words.indexWhere((w) => w.toLowerCase() == word.toLowerCase());
      });
    });

    widget.flutterTts.setCompletionHandler(() {
      setState(() {
        _currentWordIndex = -1;
      });
    });

    widget.flutterTts.speak(widget.text);
  }

  @override
  void dispose() {
    widget.flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: _words.asMap().entries.map((entry) {
          int idx = entry.key;
          String word = entry.value;

          return TextSpan(
            text: word + (idx < _words.length - 1 ? ' ' : ''),
            style: TextStyle(
              color: idx == _currentWordIndex ? Colors.white : Colors.white70,
              fontWeight: idx == _currentWordIndex ? FontWeight.bold : FontWeight.normal,
            ),
          );
        }).toList(),
      ),
    );
  }
}
