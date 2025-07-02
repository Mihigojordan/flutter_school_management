import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppColors {
  static const primaryD = Color(0xff280446);
  static const containerD = Color(0xff491475);
  static const headerD = Color(0xff18002D);
  static const dropdownMenuD = Color(0xff8654B0);
  static const white = Colors.white;
  static const whiteOpacity = Color(0xFFE8E8E8);
}

class CrisisCenterView extends StatefulWidget {
  const CrisisCenterView({super.key});

  @override
  State<CrisisCenterView> createState() => _CrisisCenterViewState();
}

class _CrisisCenterViewState extends State<CrisisCenterView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _postController = TextEditingController();
  String? userId;

  @override
  void initState() {
    super.initState();
    _ensureUserAuthenticated();
  }

  Future<void> _ensureUserAuthenticated() async {
    final auth = FirebaseAuth.instance;
    if (auth.currentUser == null) {
      await auth.signInAnonymously();
    }
    setState(() {
      userId = auth.currentUser?.uid;
    });
  }

  @override
  void dispose() {
    _postController.dispose();
    super.dispose();
  }

  void _addPost() async {
    final message = _postController.text.trim();
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (message.isEmpty || uid == null) return;

    try {
      await _firestore.collection('support_posts').add({
        'userId': uid,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      _postController.clear();
      Navigator.of(context, rootNavigator: true).pop();

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Your post has been shared successfully!'),
              backgroundColor: AppColors.containerD,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error posting message: $e'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showPostDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.containerD,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.forum_outlined, color: AppColors.white),
            SizedBox(width: 8),
            Text(
              'Share Your Experience',
              style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: TextField(
            controller: _postController,
            maxLines: 5,
            style: const TextStyle(color: AppColors.white),
            decoration: InputDecoration(
              hintText: 'Share your thoughts, feelings, or experiences...',
              hintStyle: const TextStyle(color: AppColors.whiteOpacity),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.dropdownMenuD),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.dropdownMenuD),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.white, width: 2),
              ),
              filled: true,
              fillColor: AppColors.primaryD.withOpacity(0.3),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _postController.clear();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.whiteOpacity),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _addPost,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.dropdownMenuD,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Share Post'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (userId == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: AppColors.headerD,
          elevation: 0,
          title: const Row(
            children: [
              Icon(Icons.support_agent, color: AppColors.white),
              SizedBox(width: 8),
              Text(
                'Anonymous Support',
                style: TextStyle(color: AppColors.white, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          bottom: const TabBar(
            labelColor: AppColors.white,
            unselectedLabelColor: AppColors.whiteOpacity,
            indicatorColor: AppColors.dropdownMenuD,
            indicatorWeight: 3,
            tabs: [
              Tab(icon: Icon(Icons.person), text: 'Your Posts'),
              Tab(icon: Icon(Icons.group), text: 'Community'),
            ],
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.headerD, AppColors.primaryD, AppColors.containerD],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: _showPostDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.dropdownMenuD,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 4,
                    ),
                    icon: const Icon(Icons.add_comment, size: 20),
                    label: const Text('Share Your Story',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: TabBarView(
                      children: [
                        PostListTab(isOwnPosts: true, userId: userId!, firestore: _firestore),
                        PostListTab(isOwnPosts: false, userId: userId!, firestore: _firestore),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PostListTab extends StatelessWidget {
  final bool isOwnPosts;
  final String userId;
  final FirebaseFirestore firestore;

  const PostListTab({
    super.key,
    required this.isOwnPosts,
    required this.userId,
    required this.firestore,
  });

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    return '${time.day}/${time.month}/${time.year}';
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: firestore.collection('support_posts').orderBy('timestamp', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text('Error loading posts', style: TextStyle(color: AppColors.white)),
          );
        }

        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(AppColors.dropdownMenuD)),
          );
        }

        final allPosts = snapshot.data!.docs;
        final filteredPosts = allPosts.where((doc) {
          final data = doc.data()! as Map<String, dynamic>;
          final postUserId = data['userId'] as String?;
          return isOwnPosts ? postUserId == userId : postUserId != null && postUserId != userId;
        }).toList();

        if (filteredPosts.isEmpty) {
          return Center(
            child: Text(
              isOwnPosts ? "You haven't posted yet." : "No community posts yet.",
              style: const TextStyle(color: AppColors.whiteOpacity),
            ),
          );
        }

        return ListView.builder(
          itemCount: filteredPosts.length,
          padding: const EdgeInsets.symmetric(vertical: 12),
          itemBuilder: (context, index) {
            final data = filteredPosts[index].data()! as Map<String, dynamic>;
            final message = data['message'] ?? '';
            final timestamp = data['timestamp'] as Timestamp?;
            final time = timestamp?.toDate() ?? DateTime.now();

            return Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.containerD.withOpacity(0.9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.dropdownMenuD.withOpacity(0.3), width: 1),
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                title: Text(
                  isOwnPosts ? "You" : "Anonymous",
                  style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      message,
                      style: const TextStyle(color: AppColors.white, height: 1.4),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatTime(time),
                      style: const TextStyle(color: AppColors.whiteOpacity, fontSize: 12),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
