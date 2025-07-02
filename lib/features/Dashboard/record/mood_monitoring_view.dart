// lib/features/Dashboard/record/mood/mood_monitoring_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../app/mood_data.dart';
import '../../../../services/mood_service.dart';

class MoodMonitoringPage extends StatefulWidget {
  const MoodMonitoringPage({Key? key}) : super(key: key);

  @override
  State<MoodMonitoringPage> createState() => _MoodMonitoringPageState();
}

class _MoodMonitoringPageState extends State<MoodMonitoringPage> 
    with TickerProviderStateMixin {
  final MoodService _moodService = MoodService();
  late TabController _tabController;
  
  List<MoodEntry> _moodEntries = [];
  Map<String, List<MoodEntry>> _moodsByMonth = {};
  Map<String, MoodEntry> _moodsByDate = {};
  DateTime _selectedMonth = DateTime.now();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadMoodData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadMoodData() async {
    setState(() => _isLoading = true);
    
    try {
       _moodEntries = await _moodService.getUserMoodEntriesSimple();
      _organizeMoodsByMonth();
      _organizeMoodsByDate();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading mood data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _organizeMoodsByMonth() {
    _moodsByMonth.clear();
    
    for (var entry in _moodEntries) {
      final monthKey = DateFormat('yyyy-MM').format(entry.createdAt);
      
      if (!_moodsByMonth.containsKey(monthKey)) {
        _moodsByMonth[monthKey] = [];
      }
      _moodsByMonth[monthKey]!.add(entry);
    }
  }

  void _organizeMoodsByDate() {
    _moodsByDate.clear();
    
    for (var entry in _moodEntries) {
      final dateKey = DateFormat('yyyy-MM-dd').format(entry.createdAt);
      
      // Keep the latest entry for each date
      if (!_moodsByDate.containsKey(dateKey) || 
          entry.createdAt.isAfter(_moodsByDate[dateKey]!.createdAt)) {
        _moodsByDate[dateKey] = entry;
      }
    }
  }

  Mood _getMoodFromType(String type) {
    return moods.firstWhere(
      (mood) => mood.name.toLowerCase() == type.toLowerCase(),
      orElse: () => moods[2], // Default to 'Okay'
    );
  }

  Color _getMoodColor(String type) {
    switch (type.toLowerCase()) {
      case 'great':
        return const Color(0xFF4CAF50);
      case 'good':
        return const Color(0xFF8BC34A);
      case 'okay':
        return const Color(0xFFFF9800);
      case 'sad':
        return const Color(0xFFFF5722);
      case 'miserable':
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff280446),
      appBar: AppBar(
        title: const Text(
          'Mood Monitoring',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xff18002D),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMoodData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xff8654B0),
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(text: 'Mood Chat', icon: Icon(Icons.chat_bubble_outline)),
            Tab(text: 'Mood Heatmap', icon: Icon(Icons.calendar_today)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xff8654B0)),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildMoodChat(),
                _buildMoodHeatmap(),
              ],
            ),
    );
  }

  Widget _buildMoodChat() {
    final currentMonthKey = DateFormat('yyyy-MM').format(_selectedMonth);
    final monthlyMoods = _moodsByMonth[currentMonthKey] ?? [];
    
    return Column(
      children: [
        // Month selector
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _selectedMonth = DateTime(
                      _selectedMonth.year,
                      _selectedMonth.month - 1,
                    );
                  });
                },
                icon: const Icon(Icons.chevron_left, color: Colors.white),
              ),
              Text(
                DateFormat('MMMM yyyy').format(_selectedMonth),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _selectedMonth = DateTime(
                      _selectedMonth.year,
                      _selectedMonth.month + 1,
                    );
                  });
                },
                icon: const Icon(Icons.chevron_right, color: Colors.white),
              ),
            ],
          ),
        ),
        
        // Mood statistics
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xff491475),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Entries', monthlyMoods.length.toString()),
              _buildStatItem('Avg Score', _calculateAverageScore(monthlyMoods)),
              _buildStatItem('Best Day', _getBestMoodDay(monthlyMoods)),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Chat interface
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: monthlyMoods.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    itemCount: monthlyMoods.length,
                    itemBuilder: (context, index) {
                      final mood = monthlyMoods[index];
                      return _buildMoodChatBubble(mood);
                    },
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  String _calculateAverageScore(List<MoodEntry> moods) {
    if (moods.isEmpty) return '0.0';
    
    final total = moods.fold<int>(
      0,
      (sum, mood) => sum + _getMoodScore(mood.type),
    );
    
    return (total / moods.length).toStringAsFixed(1);
  }

  String _getBestMoodDay(List<MoodEntry> moods) {
    if (moods.isEmpty) return '-';
    
    var bestMood = moods.first;
    var bestScore = _getMoodScore(bestMood.type);
    
    for (var mood in moods) {
      final score = _getMoodScore(mood.type);
      if (score > bestScore) {
        bestScore = score;
        bestMood = mood;
      }
    }
    
    return DateFormat('dd').format(bestMood.createdAt);
  }

  Widget _buildMoodChatBubble(MoodEntry mood) {
    final moodData = _getMoodFromType(mood.type);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mood emoji/icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getMoodColor(mood.type),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                _getMoodEmoji(mood.type),
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Chat bubble
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xff491475),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          mood.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        DateFormat('MMM dd, HH:mm').format(mood.createdAt),
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    mood.description,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Feeling: ${mood.emotion}',
                    style: TextStyle(
                      color: _getMoodColor(mood.type),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getMoodEmoji(String type) {
    switch (type.toLowerCase()) {
      case 'great': return '😄';
      case 'good': return '😊';
      case 'okay': return '😐';
      case 'sad': return '😢';
      case 'miserable': return '😭';
      default: return '😐';
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.mood,
            size: 64,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No mood entries for ${DateFormat('MMMM yyyy').format(_selectedMonth)}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Start tracking your mood to see insights here!',
            style: TextStyle(
              color: Colors.white60,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodHeatmap() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Month selector for heatmap
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _selectedMonth = DateTime(
                      _selectedMonth.year,
                      _selectedMonth.month - 1,
                    );
                  });
                },
                icon: const Icon(Icons.chevron_left, color: Colors.white),
              ),
              Text(
                DateFormat('MMMM yyyy').format(_selectedMonth),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _selectedMonth = DateTime(
                      _selectedMonth.year,
                      _selectedMonth.month + 1,
                    );
                  });
                },
                icon: const Icon(Icons.chevron_right, color: Colors.white),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Calendar heatmap
          _buildCalendarHeatmap(),
          
          const SizedBox(height: 24),
          
          // Legend
          _buildHeatmapLegend(),
          
          const SizedBox(height: 24),
          
          // Motivational message
          _buildMotivationalMessage(),
        ],
      ),
    );
  }

  Widget _buildCalendarHeatmap() {
    final firstDayOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final lastDayOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    final firstWeekday = firstDayOfMonth.weekday % 7;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xff491475),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Weekday headers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['S', 'M', 'T', 'W', 'T', 'F', 'S']
                .map((day) => SizedBox(
                      width: 30,
                      child: Text(
                        day,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ))
                .toList(),
          ),
          
          const SizedBox(height: 8),
          
          // Calendar grid
          ...List.generate(6, (weekIndex) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(7, (dayIndex) {
                  final dayNumber = weekIndex * 7 + dayIndex - firstWeekday + 1;
                  
                  if (dayNumber < 1 || dayNumber > daysInMonth) {
                    return const SizedBox(width: 30, height: 30);
                  }
                  
                  final date = DateTime(_selectedMonth.year, _selectedMonth.month, dayNumber);
                  final dateKey = DateFormat('yyyy-MM-dd').format(date);
                  final moodEntry = _moodsByDate[dateKey];
                  final isToday = DateFormat('yyyy-MM-dd').format(DateTime.now()) == dateKey;
                  
                  return GestureDetector(
                    onTap: () {
                      if (moodEntry != null) {
                        _showMoodDetails(moodEntry);
                      }
                    },
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: moodEntry != null 
                            ? _getMoodColor(moodEntry.type)
                            : Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: isToday 
                            ? Border.all(color: Colors.white, width: 2)
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          dayNumber.toString(),
                          style: TextStyle(
                            color: moodEntry != null ? Colors.white : Colors.white60,
                            fontSize: 12,
                            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            );
          }).where((row) {
            // Only show rows that have at least one day of the month
            final weekIndex = (row as Padding).child;
            return true;
          }).toList(),
        ],
      ),
    );
  }

  void _showMoodDetails(MoodEntry mood) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xff491475),
        title: Row(
          children: [
            Text(
              _getMoodEmoji(mood.type),
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                mood.title,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Date: ${DateFormat('MMM dd, yyyy - HH:mm').format(mood.createdAt)}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(
              'Emotion: ${mood.emotion}',
              style: TextStyle(color: _getMoodColor(mood.type)),
            ),
            const SizedBox(height: 8),
            Text(
              mood.description,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Close',
              style: TextStyle(color: Color(0xff8654B0)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeatmapLegend() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xff491475),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mood Legend',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildLegendItem('😄', 'Great', const Color(0xFF4CAF50)),
              _buildLegendItem('😊', 'Good', const Color(0xFF8BC34A)),
              _buildLegendItem('😐', 'Okay', const Color(0xFFFF9800)),
              _buildLegendItem('😢', 'Sad', const Color(0xFFFF5722)),
              _buildLegendItem('😭', 'Miserable', const Color(0xFFF44336)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String emoji, String label, Color color) {
    return Column(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildMotivationalMessage() {
    final currentMonthKey = DateFormat('yyyy-MM').format(_selectedMonth);
    final monthlyMoods = _moodsByMonth[currentMonthKey] ?? [];
    final averageScore = monthlyMoods.isEmpty ? 0.0 : 
        monthlyMoods.fold<int>(0, (sum, mood) => sum + _getMoodScore(mood.type)) / monthlyMoods.length;
    
    String message;
    Color messageColor;
    IconData messageIcon;
    
    if (averageScore >= 4.0) {
      message = "🌟 Amazing! You're having a fantastic month! Keep up the positive energy!";
      messageColor = const Color(0xFF4CAF50);
      messageIcon = Icons.celebration;
    } else if (averageScore >= 3.5) {
      message = "😊 Great job! You're maintaining a positive mood. Keep it up!";
      messageColor = const Color(0xFF8BC34A);
      messageIcon = Icons.thumb_up;
    } else if (averageScore >= 3.0) {
      message = "🌈 You're doing okay! Try some activities that make you happy today.";
      messageColor = const Color(0xFFFF9800);
      messageIcon = Icons.lightbulb;
    } else if (averageScore >= 2.0) {
      message = "💪 Tough times don't last, but tough people do. You've got this!";
      messageColor = const Color(0xFFFF5722);
      messageIcon = Icons.support;
    } else {
      message = "🤗 Remember, it's okay to have bad days. Tomorrow is a new opportunity!";
      messageColor = const Color(0xFFF44336);
      messageIcon = Icons.favorite;
    }
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: messageColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: messageColor.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Icon(
            messageIcon,
            color: messageColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: messageColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}