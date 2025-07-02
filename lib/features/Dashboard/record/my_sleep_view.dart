import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;

class AppColors {
  static const primaryD = Color(0xff280446);
  static const containerD = Color(0xff491475);
  static const headerD = Color(0xff18002D);
  static const dropdownMenuD = Color(0xff8654B0);
}

class MySleepView extends StatefulWidget {
  const MySleepView({super.key});

  @override
  State<MySleepView> createState() => _MySleepViewState();
}

class _MySleepViewState extends State<MySleepView> {
  String mood = '';
  TimeOfDay? sleepTime;
  TimeOfDay? wakeTime;
  String alarmType = 'Ringtone';
  FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  FlutterTts flutterTts = FlutterTts();

  final Map<String, String> moodEmojis = {
    '😄': 'Very Happy',
    '😊': 'Happy',
    '😐': 'Neutral',
    '😢': 'Sad',
    '😭': 'Very Sad',
  };

  @override
  void initState() {
    super.initState();
    tzdata.initializeTimeZones(); // Initialize timezone database
    initNotifications();
  }

  Future<void> initNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        showWakeUpDialog();
      },
    );
  }

  Future<void> scheduleAlarm() async {
    final now = DateTime.now();
    final selectedDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      wakeTime!.hour,
      wakeTime!.minute,
    );

    // Convert to TZDateTime in the local timezone
    final tz.TZDateTime scheduledTZDateTime = tz.TZDateTime.from(
      selectedDateTime,
      tz.local,
    );

    await notificationsPlugin.zonedSchedule(
      0,
      'Wake Up!',
      'It\'s time to wake up!',
      scheduledTZDateTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'sleep_channel',
          'Sleep Alarm',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  void showWakeUpDialog() async {
    await flutterTts.speak("Good morning! Time to get up. Stretch, hydrate and smile!");
    if (mounted) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Alarm!'),
          content: const Text("Time to wake up!"),
          actions: [
            TextButton(
              child: const Text('Got it'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }
  }

  Future<void> saveToFirebase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('sleepLogs').add({
      'userId': user.uid,
      'mood': mood,
      'sleepTime': '${sleepTime!.hour}:${sleepTime!.minute}',
      'wakeTime': '${wakeTime!.hour}:${wakeTime!.minute}',
      'alarmType': alarmType,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await scheduleAlarm();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sleep data saved & alarm set')),
    );
  }

  Future<void> pickTime(BuildContext context, bool isSleepTime) async {
    final result = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (result != null) {
      setState(() {
        if (isSleepTime) {
          sleepTime = result;
        } else {
          wakeTime = result;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFormComplete = mood.isNotEmpty && sleepTime != null && wakeTime != null;

    return Scaffold(
      backgroundColor: AppColors.primaryD,
      appBar: AppBar(
        backgroundColor: AppColors.headerD,
        title: const Text('My Sleep', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.containerD,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Mood Before Sleep",
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: moodEmojis.entries.map((entry) {
                      return ChoiceChip(
                        label: Text('${entry.key} ${entry.value}',
                            style: TextStyle(
                              color:
                                  mood == entry.value ? const Color.fromARGB(255, 34, 33, 33) : const Color.fromARGB(255, 49, 46, 46),
                            )),
                        selected: mood == entry.value,
                        selectedColor: AppColors.dropdownMenuD,
                        onSelected: (_) => setState(() => mood = entry.value),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.dropdownMenuD,
                          ),
                          onPressed: () => pickTime(context, true),
                          child: Text(
                            sleepTime == null
                                ? "Set Sleep Time"
                                : "Sleep: ${sleepTime!.format(context)}",
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.dropdownMenuD,
                          ),
                          onPressed: () => pickTime(context, false),
                          child: Text(
                            wakeTime == null
                                ? "Set Wake Time"
                                : "Wake: ${wakeTime!.format(context)}",
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: alarmType,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.dropdownMenuD,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    dropdownColor: AppColors.dropdownMenuD,
                    style: const TextStyle(color: Colors.white),
                    items: ['Ringtone', 'Vibration', 'Silent']
                        .map((e) => DropdownMenuItem(
                              value: e,
                              child: Text(e, style: const TextStyle(color: Colors.white)),
                            ))
                        .toList(),
                    onChanged: (val) => setState(() => alarmType = val!),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: isFormComplete ? saveToFirebase : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Center(
                      child: Text(
                        'Save & Set Alarm',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
