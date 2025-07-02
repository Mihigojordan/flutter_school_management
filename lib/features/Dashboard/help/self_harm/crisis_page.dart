import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

class SelfHarmCrisisPage extends StatelessWidget {
  const SelfHarmCrisisPage({super.key});

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      throw 'Could not launch $phoneNumber';
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> emergencyContacts = [
      {
        'name': 'Emergency Services',
        'number': '911',
      },
      {
        'name': 'Crisis Text Line',
        'number': '741741',
      },
      {
        'name': 'Suicide Prevention',
        'number': '988',
      },
      {
        'name': 'Crisis Counselor',
        'number': '1-800-366-8288',
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xff280446),
      appBar: AppBar(
        backgroundColor: const Color(0xff18002D),
        title: const Text(
          'Emergency Contacts',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => GoRouter.of(context).go('/dashboard/help/self-harm'),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Simple header
              const Text(
                'Immediate help contacts:',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 20),
              
              // Emergency Contacts List
              Expanded(
                child: ListView.builder(
                  itemCount: emergencyContacts.length,
                  itemBuilder: (context, index) {
                    final contact = emergencyContacts[index];
                    return Card(
                      color: const Color(0xff491475),
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        title: Text(
                          contact['name'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        trailing: Text(
                          contact['number'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onTap: () => _makePhoneCall(contact['number']),
                      ),
                    );
                  },
                ),
              ),
              
              // Emergency reminder
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xff491475),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Tap any number to call immediately',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}