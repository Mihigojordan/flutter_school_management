import 'package:flutter/material.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);

  static const _appDescription = '''
Nepanir is a modern app designed to enhance your daily productivity with seamless features, intuitive design, and reliable performance. 

It provides you with tools and settings customization to optimize your experience and keep everything organized effortlessly.

Explore the app to discover how Nepanir can simplify your life and keep you connected to what matters most.
''';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff280446),
      appBar: AppBar(
        backgroundColor: const Color(0xff280446),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Nepanir',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: SingleChildScrollView(  // To avoid overflow if small screen
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                decoration: BoxDecoration(
                  color: const Color(0xff8654B0),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  _appDescription,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                    height: 1.5,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const SizedBox(height: 24),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  // Force a crash to test Crashlytics
                  FirebaseCrashlytics.instance.crash();
                },
                child: const Text(
                  'Force Crash (Test Crashlytics)',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
