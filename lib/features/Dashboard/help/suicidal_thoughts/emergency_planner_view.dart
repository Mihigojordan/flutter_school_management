// features/Dashboard/help/suicidal_thoughts/emergency_planner_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class EmergencyPlannerView extends ConsumerStatefulWidget {
  const EmergencyPlannerView({super.key});

  @override
  ConsumerState<EmergencyPlannerView> createState() => _EmergencyPlannerViewState();
}

class _EmergencyPlannerViewState extends ConsumerState<EmergencyPlannerView> {
  final _formKey = GlobalKey<FormState>();
  final _warningSignsController = TextEditingController();
  final _copingStrategiesController = TextEditingController();
  final _supportPeopleController = TextEditingController();
  final _professionalContactsController = TextEditingController();
  final _environmentController = TextEditingController();
  final _reasonsController = TextEditingController();

  @override
  void dispose() {
    _warningSignsController.dispose();
    _copingStrategiesController.dispose();
    _supportPeopleController.dispose();
    _professionalContactsController.dispose();
    _environmentController.dispose();
    _reasonsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a2e),
      appBar: AppBar(
        title: const Text('Emergency Safety Plan'),
        backgroundColor: const Color(0xFF1a1a2e),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard/help/suicidal-thoughts'),
        ),
        actions: [
          TextButton(
            onPressed: _savePlan,
            child: const Text(
              'Save',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFE74C3C).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE74C3C).withOpacity(0.3)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.medical_services, color: Color(0xFFE74C3C), size: 24),
                        SizedBox(width: 8),
                        Text(
                          'Safety Plan',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Create a personalized plan to help you stay safe during difficult moments.',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              _buildSectionCard(
                '1. Warning Signs',
                'Recognize when you might be in crisis',
                _warningSignsController,
                'List thoughts, feelings, or situations that might trigger a crisis...',
                Icons.warning,
                const Color(0xFFF39C12),
              ),
              
              _buildSectionCard(
                '2. Coping Strategies',
                'Things you can do to help yourself feel better',
                _copingStrategiesController,
                'Activities that help you cope (exercise, music, art, etc.)...',
                Icons.self_improvement,
                const Color(0xFF3498DB),
              ),
              
              _buildSectionCard(
                '3. People for Support',
                'Friends and family who can help',
                _supportPeopleController,
                'Names and phone numbers of people you trust...',
                Icons.people,
                const Color(0xFF2ECC71),
              ),
              
              _buildSectionCard(
                '4. Professional Contacts',
                'Healthcare providers and crisis resources',
                _professionalContactsController,
                'Therapist, doctor, crisis hotline numbers...',
                Icons.medical_information,
                const Color(0xFF9B59B6),
              ),
              
              _buildSectionCard(
                '5. Making Environment Safe',
                'Remove or secure things that could cause harm',
                _environmentController,
                'Steps to make your space safer...',
                Icons.home,
                const Color(0xFFE67E22),
              ),
              
              _buildSectionCard(
                '6. Reasons for Living',
                'What makes life worth living for you',
                _reasonsController,
                'Family, goals, values, experiences you want to have...',
                Icons.favorite,
                const Color(0xFFE91E63),
              ),
              
              const SizedBox(height: 32),
              
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF491475),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.info, color: Colors.white, size: 24),
                    SizedBox(height: 8),
                    Text(
                      'Remember: This plan is a tool to help you, but it\'s not a substitute for professional help. If you\'re in immediate danger, call 988 or go to your nearest emergency room.',
                      style: TextStyle(color: Colors.white, fontSize: 14),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(
    String title,
    String subtitle,
    TextEditingController controller,
    String hintText,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF2D2D42),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: controller,
              maxLines: 4,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: const Color(0xFF1a1a2e),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _savePlan() {
    if (_formKey.currentState!.validate()) {
      // Here you would typically save to your database
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Safety plan saved successfully'),
          backgroundColor: Color(0xFF2ECC71),
        ),
      );
      context.go('/dashboard/help/suicidal-thoughts');
    }
  }
}