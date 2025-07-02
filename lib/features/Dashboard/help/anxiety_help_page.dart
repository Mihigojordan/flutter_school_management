import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AnxietyHelpPage extends StatelessWidget {
  const AnxietyHelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> anxietyOptions = [
      {
        'title': 'Panic Attack Tips',
        'icon': Icons.lightbulb_outline,
        'route': '/dashboard/help/anxiety/tips',
        'description': 'Learn techniques to manage panic attacks',
      },
      {
        'title': 'Arithmetic Exercise',
        'icon': Icons.calculate_outlined,
        'route': '/dashboard/help/anxiety/arithmetic',
        'description': 'Focus your mind with simple math exercises',
      },
      {
        'title': 'Ball Games',
        'icon': Icons.sports_soccer_outlined,
        'route': '/dashboard/help/anxiety/ball-games',
        'description': 'Interactive games to reduce anxiety',
      },
      {
        'title': 'See Saw Game',
        'icon': Icons.balance_outlined,
        'route': '/dashboard/help/anxiety/seesaw',
        'description': 'Calming balance game for relaxation',
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xff280446), // primaryD
      appBar: AppBar(
        backgroundColor: const Color(0xff18002D), // headerD
        title: const Text(
          'Anxiety & Panic Attacks',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => GoRouter.of(context).go('/dashboard/home'),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xff491475), // containerD
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.psychology_outlined,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Take Control',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Choose an activity to help manage your anxiety',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              
              // Options List
              const Text(
                'Choose an Activity',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              Expanded(
                child: ListView.builder(
                  itemCount: anxietyOptions.length,
                  itemBuilder: (context, index) {
                    final option = anxietyOptions[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: InkWell(
                        onTap: () => GoRouter.of(context).go(option['route']),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xff491475), // containerD
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xff8654B0), // dropdownMenuD
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  option['icon'],
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      option['title'],
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      option['description'],
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white70,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}