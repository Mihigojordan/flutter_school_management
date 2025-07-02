import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatView extends StatefulWidget {
  const ChatView({super.key});

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  // Custom colors
  static const primaryD = Color(0xff280446);
  static const containerD = Color(0xff491475);
  static const headerD = Color(0xff18002D);
  static const dropdownMenuD = Color(0xff8654B0);

  final String geminiApiKey = 'AIzaSyBsibjUpIOqpCol2ZIkU6T5WRPhJeQRDVU';
  final TextEditingController _aiController = TextEditingController();
  final TextEditingController _liveChatController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ScrollController _liveChatScrollController = ScrollController();

  final List<ChatMessage> _aiMessages = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _aiMessages.add(ChatMessage(text: "Hi! I'm your AI assistant. How can I help you?", isUser: false));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _aiController.dispose();
    _liveChatController.dispose();
    _scrollController.dispose();
    _liveChatScrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom(ScrollController controller) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.hasClients) {
        controller.animateTo(
          controller.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> sendGeminiMessage(String message) async {
    if (message.isEmpty) return;

    setState(() {
      _aiMessages.add(ChatMessage(text: message, isUser: true));
    });

    // Hide keyboard and scroll to bottom
    FocusScope.of(context).unfocus();
    _scrollToBottom(_scrollController);

    try {
      final url = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$geminiApiKey');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "contents": [
            {
              "parts": [
                {"text": message}
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final reply = json['candidates'][0]['content']['parts'][0]['text'];

        setState(() {
          _aiMessages.add(ChatMessage(text: reply, isUser: false));
        });
      } else {
        print('API ERROR STATUS: ${response.statusCode}');
        print('API ERROR BODY: ${response.body}');
        setState(() {
          _aiMessages.add(ChatMessage(
            text: "Error reaching Gemini AI: ${response.statusCode}",
            isUser: false,
          ));
        });
      }
    } catch (e) {
      print('Network exception: $e');
      setState(() {
        _aiMessages.add(ChatMessage(
          text: "Network error. Please try again.",
          isUser: false,
        ));
      });
    }

    _scrollToBottom(_scrollController);
  }

  void sendLiveChatMessage() {
    final text = _liveChatController.text.trim();
    if (text.isEmpty) return;

    FirebaseFirestore.instance.collection('live_chat').add({
      'message': text,
      'timestamp': Timestamp.now(),
      'user': 'Anonymous',
    });

    _liveChatController.clear();
    
    // Hide keyboard and scroll to bottom
    FocusScope.of(context).unfocus();
    _scrollToBottom(_liveChatScrollController);
  }

  Widget buildAiChatTab() {
    return Container(
      color: primaryD,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 80), // Space for your bottom navigation
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: _aiMessages.length,
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  itemBuilder: (context, index) {
                    final msg = _aiMessages[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Align(
                        alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.8,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: msg.isUser ? containerD : dropdownMenuD,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            msg.text,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Container(
                color: headerD,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 40,
                        child: TextField(
                          controller: _aiController,
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                          decoration: InputDecoration(
                            hintText: "Ask Nepanir...",
                            hintStyle: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: const BorderSide(color: dropdownMenuD),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: const BorderSide(color: dropdownMenuD),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: const BorderSide(color: Colors.white),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical:8 ),
                            filled: true,
                            fillColor: containerD,
                          ),
                          onSubmitted: (value) {
                            sendGeminiMessage(value.trim());
                            _aiController.clear();
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      height: 32,
                      width: 32,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.send, color: Colors.white, size: 16),
                        onPressed: () {
                          sendGeminiMessage(_aiController.text.trim());
                          _aiController.clear();
                        },
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

  Widget buildLiveChatTab() {
    return Container(
      color: primaryD,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 80), // Space for your bottom navigation
          child: Column(
            children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('live_chat')
                      .orderBy('timestamp', descending: false)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    }
                    final docs = snapshot.data!.docs;
                    
                    // Auto scroll to bottom when new messages arrive
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _scrollToBottom(_liveChatScrollController);
                    });
                    
                    return ListView.builder(
                      controller: _liveChatScrollController,
                      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final data = docs[index].data() as Map<String, dynamic>;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Container(
                              constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width * 0.8,
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: dropdownMenuD,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                data['message'] ?? '',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              Container(
                color: headerD,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 40,
                        child: TextField(
                          controller: _liveChatController,
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                          decoration: InputDecoration(
                            hintText: "Type your message...",
                            hintStyle: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: const BorderSide(color: dropdownMenuD),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: const BorderSide(color: dropdownMenuD),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: const BorderSide(color: Colors.white),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            filled: true,
                            fillColor: containerD,
                          ),
                          onSubmitted: (value) {
                            sendLiveChatMessage();
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      height: 32,
                      width: 32,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: const Icon(Icons.send, color: Colors.white, size: 16),
                        onPressed: sendLiveChatMessage,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryD,
      appBar: AppBar(
        backgroundColor: headerD,
        title: const Text(
          'Chat Center',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          labelStyle: const TextStyle(fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          tabs: const [
            Tab(text: "AI Chatbot", icon: Icon(Icons.smart_toy, size: 16)),
            Tab(text: "Live Chat", icon: Icon(Icons.chat, size: 16)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          buildAiChatTab(),
          buildLiveChatTab(),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}