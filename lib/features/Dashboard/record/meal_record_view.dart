import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Custom Dark Theme Colors
class AppColors {
  static const primaryD = Color(0xff280446);
  static const containerD = Color(0xff491475);
  static const headerD = Color(0xff18002D);
  static const dropdownMenuD = Color(0xff8654B0);
  static const white = Colors.white;
}

class MealRecordView extends StatefulWidget {
  const MealRecordView({super.key});

  @override
  State<MealRecordView> createState() => _MealRecordViewState();
}

class _MealRecordViewState extends State<MealRecordView> {
  final TextEditingController _mealController = TextEditingController();
  TimeOfDay? _selectedTime;
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  List<Map<String, dynamic>> scheduledMeals = [];

  User? currentUser;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    tz.initializeTimeZones();
    _loadCurrentUser();
  }

  void _loadCurrentUser() {
    currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      _fetchMeals();
    }
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings = InitializationSettings(android: androidSettings);

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _handleNotificationAction,
    );
  }

  void _handleNotificationAction(NotificationResponse response) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.containerD,
        title: const Text("Meal Notification", style: TextStyle(color: AppColors.white)),
        content: const Text("Did you start cooking or already ate?", style: TextStyle(color: AppColors.white)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Ignore", style: TextStyle(color: AppColors.dropdownMenuD)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Meal confirmed")),
              );
            },
            child: const Text("Confirm", style: TextStyle(color: AppColors.dropdownMenuD)),
          ),
        ],
      ),
    );
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _scheduleMealNotification() async {
    if (_mealController.text.trim().isEmpty || _selectedTime == null) return;

    final now = DateTime.now();
    final scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      _selectedTime!.hour,
      _selectedTime!.minute,
    );

    // If scheduled time already passed today, schedule for tomorrow
    DateTime finalScheduledDate = scheduledDate.isBefore(now)
        ? scheduledDate.add(const Duration(days: 1))
        : scheduledDate;

    final androidDetails = AndroidNotificationDetails(
      'meal_channel',
      'Meal Reminder',
      importance: Importance.max,
      priority: Priority.high,
    );
    final details = NotificationDetails(android: androidDetails);
    final tz.TZDateTime tzScheduledDate = tz.TZDateTime.from(finalScheduledDate, tz.local);

    // Use a unique id based on timestamp
    final notificationId = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    await _notificationsPlugin.zonedSchedule(
      notificationId,
      'Time to prepare your meal',
      'Meal: ${_mealController.text}',
      tzScheduledDate,
      details,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    if (currentUser != null) {
      // Save meal to Firestore with notificationId for deletion if needed
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .collection('meals')
          .add({
        'mealName': _mealController.text,
        'hour': _selectedTime!.hour,
        'minute': _selectedTime!.minute,
        'notificationId': notificationId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Reload meals from Firestore to update UI
      await _fetchMeals();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Meal "${_mealController.text}" scheduled at ${_selectedTime!.format(context)}')),
      );
    }

    _mealController.clear();
    _selectedTime = null;
  }

  Future<void> _fetchMeals() async {
    if (currentUser == null) return;

    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .collection('meals')
        .orderBy('timestamp', descending: true)
        .get();

    final List<Map<String, dynamic>> meals = querySnapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'docId': doc.id,
        'mealName': data['mealName'] ?? '',
        'hour': data['hour'] ?? 0,
        'minute': data['minute'] ?? 0,
        'notificationId': data['notificationId'],
      };
    }).toList();

    setState(() {
      scheduledMeals = meals;
    });
  }

  Future<void> _deleteMeal(int index) async {
    if (currentUser == null) return;
    final meal = scheduledMeals[index];

    // Cancel scheduled notification if any
    final notificationId = meal['notificationId'];
    if (notificationId != null) {
      await _notificationsPlugin.cancel(notificationId);
    }

    // Delete from Firestore
    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser!.uid)
        .collection('meals')
        .doc(meal['docId'])
        .delete();

    // Remove from local list and update UI
    setState(() {
      scheduledMeals.removeAt(index);
    });
  }

  String _formatTime(int hour, int minute) {
    final time = TimeOfDay(hour: hour, minute: minute);
    return time.format(context);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.primaryD,
        appBar: AppBar(
          backgroundColor: AppColors.headerD,
          title: const Text('Meal Record', style: TextStyle(color: AppColors.white)),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Add Meal'),
              Tab(text: 'Scheduled Meals'),
            ],
            labelColor: AppColors.white,
            indicatorColor: AppColors.dropdownMenuD,
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: Add Meal
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _mealController,
                    style: const TextStyle(color: AppColors.white),
                    decoration: InputDecoration(
                      labelText: 'Meal Name',
                      labelStyle: const TextStyle(color: AppColors.white),
                      filled: true,
                      fillColor: AppColors.containerD,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: AppColors.dropdownMenuD),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () => _selectTime(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.dropdownMenuD,
                          foregroundColor: AppColors.white,
                        ),
                        child: const Text("Select Time"),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _selectedTime == null
                            ? "No time selected"
                            : "Selected: ${_selectedTime!.format(context)}",
                        style: const TextStyle(color: AppColors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _scheduleMealNotification,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.containerD,
                      foregroundColor: AppColors.white,
                      minimumSize: const Size.fromHeight(50),
                    ),
                    child: const Text("Save Meal"),
                  ),
                ],
              ),
            ),

            // Tab 2: Scheduled Meals
            scheduledMeals.isEmpty
                ? const Center(
                    child: Text(
                      "No meals scheduled yet",
                      style: TextStyle(color: AppColors.white),
                    ),
                  )
                : ListView.builder(
                    itemCount: scheduledMeals.length,
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      final meal = scheduledMeals[index];
                      final mealName = meal['mealName'] ?? '';
                      final hour = meal['hour'] ?? 0;
                      final minute = meal['minute'] ?? 0;
                      return Card(
                        color: AppColors.containerD,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          title: Text(
                            mealName,
                            style: const TextStyle(color: AppColors.white),
                          ),
                          subtitle: Text(
                            "Scheduled at: ${_formatTime(hour, minute)}",
                            style: const TextStyle(color: Colors.white70),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: AppColors.dropdownMenuD),
                            onPressed: () => _deleteMeal(index),
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
