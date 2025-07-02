import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppColors {
  static const primaryD = Color(0xff280446);
  static const containerD = Color(0xff491475);
  static const headerD = Color(0xff18002D);
  static const dropdownMenuD = Color(0xff8654B0);
}

class JourneyView extends StatefulWidget {
  const JourneyView({super.key});

  @override
  State<JourneyView> createState() => _JourneyViewState();
}

class _JourneyViewState extends State<JourneyView> {
  final _gratitudeController = TextEditingController();
  final _dayGreatController = TextEditingController();
  final _feelingController = TextEditingController();
  final _goodThingsController = TextEditingController();
  final _improveController = TextEditingController();
  bool _isSaving = false;

  User? get user => FirebaseAuth.instance.currentUser;

  Future<void> saveJourney() async {
    if (user == null) return;
    setState(() => _isSaving = true);

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('journey')
          .add({
        'gratitude': _gratitudeController.text.trim(),
        'dayGreat': _dayGreatController.text.trim(),
        'feeling': _feelingController.text.trim(),
        'goodThings': _goodThingsController.text.trim(),
        'improve': _improveController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      });

      _gratitudeController.clear();
      _dayGreatController.clear();
      _feelingController.clear();
      _goodThingsController.clear();
      _improveController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Journey saved successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving journey: $e')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Stream<QuerySnapshot> getJourneyStream() {
    if (user == null) return const Stream.empty();
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .collection('journey')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.primaryD,
        appBar: AppBar(
          backgroundColor: AppColors.headerD,
          title: const Text('Journey', style: TextStyle(color: Colors.white)),
          centerTitle: true,
          bottom: const TabBar(
            labelColor: Colors.white,                // active tab text color
           unselectedLabelColor: Colors.white70,    // inactive tab text color
            tabs: [
              Tab(icon: Icon(Icons.edit_note), text: 'Add Entry'),
              Tab(icon: Icon(Icons.book), text: 'View Entries'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Add Entry
            Padding(
              padding: const EdgeInsets.all(12),
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.containerD,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      buildInput('What am I grateful for?', _gratitudeController),
                      buildInput('What made my day great?', _dayGreatController),
                      buildInput('How do I feel?', _feelingController),
                      buildInput('Three good things that happened today', _goodThingsController),
                      buildInput('How can this day be improved?', _improveController),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSaving ? null : saveJourney,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                          child: _isSaving
                              ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                              : const Text('Save Entry', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),

            // View Entries
            Padding(
              padding: const EdgeInsets.all(12),
              child: StreamBuilder<QuerySnapshot>(
                stream: getJourneyStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text('No entries yet.',
                          style: TextStyle(color: Colors.white)),
                    );
                  }

                  final entries = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      final data = entries[index];
                      final timestamp = data['timestamp'] as Timestamp?;
                      final date = timestamp?.toDate();

                      return Card(
                        color: AppColors.containerD,
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (date != null)
                                Text(
                                  '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}',
                                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                                ),
                              const SizedBox(height: 6),
                              buildEntryField('Grateful for', data['gratitude']),
                              buildEntryField('Day was great because', data['dayGreat']),
                              buildEntryField('Feeling', data['feeling']),
                              buildEntryField('3 Good Things', data['goodThings']),
                              buildEntryField('Improvement', data['improve']),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildInput(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: TextField(
        controller: controller,
        maxLines: 2,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white, fontSize: 13),
          filled: true,
          fillColor: AppColors.dropdownMenuD.withOpacity(0.5),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
        ),
      ),
    );
  }

  Widget buildEntryField(String title, String? value) {
    if (value == null || value.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 3.0),
      child: Text(
        '$title:\n$value',
        style: const TextStyle(color: Colors.white, fontSize: 13),
      ),
    );
  }
}
