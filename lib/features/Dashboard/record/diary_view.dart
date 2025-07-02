import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AppColors {
  static const primaryD = Color(0xff280446);
  static const containerD = Color(0xff491475);
  static const headerD = Color(0xff18002D);
  static const dropdownMenuD = Color(0xff8654B0);
}

class DiaryView extends StatefulWidget {
  const DiaryView({super.key});

  @override
  State<DiaryView> createState() => _DiaryViewState();
}

class _DiaryViewState extends State<DiaryView> {
  final TextEditingController _noteController = TextEditingController();
  bool _isSaving = false;
  bool _isEditing = false;
  String? _editingNoteId;

  User? get _user => FirebaseAuth.instance.currentUser;

  Future<void> saveNote() async {
    if (_user == null || _noteController.text.trim().isEmpty) return;

    setState(() => _isSaving = true);

    try {
      if (_isEditing && _editingNoteId != null) {
        await FirebaseFirestore.instance
            .collection('dailyNotes')
            .doc(_editingNoteId)
            .update({
          'note': _noteController.text.trim(),
          'timestamp': FieldValue.serverTimestamp(),
        });
        _isEditing = false;
        _editingNoteId = null;
      } else {
        await FirebaseFirestore.instance.collection('dailyNotes').add({
          'userId': _user!.uid,
          'note': _noteController.text.trim(),
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
      _noteController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isEditing ? 'Note updated' : 'Note saved')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving note: $e')),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  Stream<List<DocumentSnapshot>> getUserNotesStream() {
    if (_user == null) return const Stream.empty();

    return FirebaseFirestore.instance
        .collection('dailyNotes')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.where((doc) => doc['userId'] == _user!.uid).toList());
  }

  Future<void> _deleteNote(String noteId) async {
    try {
      await FirebaseFirestore.instance.collection('dailyNotes').doc(noteId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Note deleted')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting note: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.primaryD,
        appBar: AppBar(
          backgroundColor: AppColors.headerD,
          title: const Text('Diary', style: TextStyle(color: Colors.white)),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.note_add), text: 'Add Note'),
              Tab(icon: Icon(Icons.view_list), text: 'View Notes'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Add Note Tab
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.containerD,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      _isEditing ? "Edit your note" : "Write your note for today",
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _noteController,
                      maxLines: 5,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Enter your thoughts...',
                        hintStyle: TextStyle(color: Colors.grey[300]),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: AppColors.dropdownMenuD.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _isSaving ? null : saveNote,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                      ),
                      child: _isSaving
                          ? const CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2)
                          : Text(_isEditing ? 'Update Note' : 'Save Note',
                              style: const TextStyle(color: Colors.white)),
                    ),
                    if (_isEditing)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _isEditing = false;
                            _editingNoteId = null;
                            _noteController.clear();
                          });
                        },
                        child: const Text('Cancel Edit',
                            style: TextStyle(color: Colors.red)),
                      ),
                  ],
                ),
              ),
            ),

            // View Notes Tab
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: StreamBuilder<List<DocumentSnapshot>>(
                stream: getUserNotesStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text('No notes yet.',
                          style: TextStyle(color: Colors.white)),
                    );
                  }

                  final notes = snapshot.data!;

                  return ListView.builder(
                    itemCount: notes.length,
                    itemBuilder: (context, index) {
                      final note = notes[index];
                      final text = note['note'] ?? '';
                      final timestamp = note['timestamp'] as Timestamp?;
                      final date = timestamp?.toDate();

                      return Card(
                        color: AppColors.containerD,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        child: ListTile(
                          title: Text(
                            text,
                            style: const TextStyle(color: Colors.white),
                          ),
                          subtitle: date != null
                              ? Text(
                                  '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}',
                                  style: const TextStyle(color: Colors.white60),
                                )
                              : null,
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                backgroundColor: AppColors.containerD,
                                title: const Text(
                                  'Delete Note',
                                  style: TextStyle(color: Colors.white),
                                ),
                                content: const Text(
                                  'Are you sure you want to delete this note?',
                                  style: TextStyle(color: Colors.white70),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(ctx).pop(),
                                    child: const Text('Cancel',
                                        style: TextStyle(color: Colors.grey)),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(ctx).pop();
                                      _deleteNote(note.id);
                                    },
                                    child: const Text('Delete',
                                        style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            ),
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
}
