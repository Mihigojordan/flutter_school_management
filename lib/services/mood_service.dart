// lib/services/mood_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

class MoodEntry {
  final String id;
  final String userId;
  final String type;
  final String title;
  final String emotion;
  final String description;
  final DateTime createdAt;

  MoodEntry({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.emotion,
    required this.description,
    required this.createdAt,
  });

  // Updated toMap to use Firestore Timestamp
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'title': title,
      'emotion': emotion,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt), // Changed to Timestamp
    };
  }

  // Updated fromMap to handle both Timestamp and String formats
  factory MoodEntry.fromMap(Map<String, dynamic> map) {
    DateTime createdAt;
    
    // Handle both Timestamp and String formats for backward compatibility
    if (map['createdAt'] is Timestamp) {
      createdAt = (map['createdAt'] as Timestamp).toDate();
    } else if (map['createdAt'] is String) {
      createdAt = DateTime.parse(map['createdAt']);
    } else {
      createdAt = DateTime.now(); // Fallback
    }

    return MoodEntry(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      type: map['type'] ?? '',
      title: map['title'] ?? '',
      emotion: map['emotion'] ?? '',
      description: map['description'] ?? '',
      createdAt: createdAt,
    );
  }

  // Helper method to create from Firestore document
  factory MoodEntry.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MoodEntry.fromMap({...data, 'id': doc.id});
  }
}

class MoodService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Uuid _uuid = const Uuid();

  // Collection reference for better organization
  CollectionReference get _moodCollection => 
      _firestore.collection('mood_entries');

  Future<void> saveMoodEntry({
    required String type,
    required String title,
    required String emotion,
    required String description,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final moodEntry = MoodEntry(
        id: _uuid.v4(),
        userId: user.uid,
        type: type,
        title: title,
        emotion: emotion,
        description: description,
        createdAt: DateTime.now(),
      );

      // Use the document ID from the MoodEntry
      await _moodCollection
          .doc(moodEntry.id)
          .set(moodEntry.toMap());
          
    } catch (e) {
      throw Exception('Failed to save mood entry: $e');
    }
  }

  Future<List<MoodEntry>> getUserMoodEntries() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // This query requires a composite index: userId (ASC) + createdAt (DESC)
      final querySnapshot = await _moodCollection
          .where('userId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => MoodEntry.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch mood entries: $e');
    }
  }

  // Alternative method without ordering (no index required)
  Future<List<MoodEntry>> getUserMoodEntriesSimple() async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Simple query without ordering - no index required
      final querySnapshot = await _moodCollection
          .where('userId', isEqualTo: user.uid)
          .get();

      final entries = querySnapshot.docs
          .map((doc) => MoodEntry.fromFirestore(doc))
          .toList();

      // Sort in Dart instead of Firestore
      entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      return entries;
    } catch (e) {
      throw Exception('Failed to fetch mood entries: $e');
    }
  }

  // Get mood entries for a specific date range
  Future<List<MoodEntry>> getMoodEntriesForDateRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final querySnapshot = await _moodCollection
          .where('userId', isEqualTo: user.uid)
          .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('createdAt', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .get();

      final entries = querySnapshot.docs
          .map((doc) => MoodEntry.fromFirestore(doc))
          .toList();

      // Sort by date descending
      entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      return entries;
    } catch (e) {
      throw Exception('Failed to fetch mood entries for date range: $e');
    }
  }

  // Get mood entries for a specific month
  Future<List<MoodEntry>> getMoodEntriesForMonth({
    required int year,
    required int month,
  }) async {
    final startDate = DateTime(year, month, 1);
    final endDate = DateTime(year, month + 1, 0, 23, 59, 59, 999);
    
    return getMoodEntriesForDateRange(
      startDate: startDate,
      endDate: endDate,
    );
  }

  // Update an existing mood entry
  Future<void> updateMoodEntry({
    required String entryId,
    required String type,
    required String title,
    required String emotion,
    required String description,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Verify the entry exists and belongs to the user
      final doc = await _moodCollection.doc(entryId).get();
      if (!doc.exists) {
        throw Exception('Mood entry not found');
      }

      final data = doc.data() as Map<String, dynamic>;
      if (data['userId'] != user.uid) {
        throw Exception('Unauthorized to update this mood entry');
      }

      // Update the entry
      await _moodCollection.doc(entryId).update({
        'type': type,
        'title': title,
        'emotion': emotion,
        'description': description,
        // Keep the original createdAt, don't update it
      });
    } catch (e) {
      throw Exception('Failed to update mood entry: $e');
    }
  }

  // Delete a mood entry
  Future<void> deleteMoodEntry(String entryId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Verify the entry exists and belongs to the user
      final doc = await _moodCollection.doc(entryId).get();
      if (!doc.exists) {
        throw Exception('Mood entry not found');
      }

      final data = doc.data() as Map<String, dynamic>;
      if (data['userId'] != user.uid) {
        throw Exception('Unauthorized to delete this mood entry');
      }

      await _moodCollection.doc(entryId).delete();
    } catch (e) {
      throw Exception('Failed to delete mood entry: $e');
    }
  }

  // Real-time stream of mood entries
  Stream<List<MoodEntry>> getMoodEntriesStream() {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.error('User not authenticated');
    }

    return _moodCollection
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => MoodEntry.fromFirestore(doc))
          .toList();
    });
  }

  // Get mood statistics
  Future<Map<String, dynamic>> getMoodStatistics() async {
    try {
      final entries = await getUserMoodEntries();
      
      if (entries.isEmpty) {
        return {
          'totalEntries': 0,
          'averageScore': 0.0,
          'moodCounts': <String, int>{},
          'streakDays': 0,
        };
      }

      // Calculate mood counts and total score
      Map<String, int> moodCounts = {};
      int totalScore = 0;

      for (var entry in entries) {
        moodCounts[entry.type] = (moodCounts[entry.type] ?? 0) + 1;
        totalScore += _getMoodScore(entry.type);
      }

      return {
        'totalEntries': entries.length,
        'averageScore': entries.isNotEmpty ? totalScore / entries.length : 0.0,
        'moodCounts': moodCounts,
        'streakDays': _calculateStreak(entries),
      };
    } catch (e) {
      throw Exception('Failed to get mood statistics: $e');
    }
  }

  // Helper method to get mood score
  int _getMoodScore(String type) {
    switch (type.toLowerCase()) {
      case 'great': return 5;
      case 'good': return 4;
      case 'okay': return 3;
      case 'sad': return 2;
      case 'miserable': return 1;
      default: return 3;
    }
  }

  // Helper method to calculate consecutive days streak
  int _calculateStreak(List<MoodEntry> entries) {
    if (entries.isEmpty) return 0;

    entries.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    int streak = 0;
    DateTime currentDate = DateTime.now();
    
    for (var entry in entries) {
      final entryDate = DateTime(
        entry.createdAt.year,
        entry.createdAt.month,
        entry.createdAt.day,
      );
      
      final checkDate = DateTime(
        currentDate.year,
        currentDate.month,
        currentDate.day,
      );
      
      if (entryDate.isAtSameMomentAs(checkDate)) {
        streak++;
        currentDate = currentDate.subtract(const Duration(days: 1));
      } else if (entryDate.isBefore(checkDate)) {
        break;
      }
    }
    
    return streak;
  }
}