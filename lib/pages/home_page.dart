import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crud_tutorial_app/services/firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  // firestore
  final FirestoreService firestoreService = FirestoreService();

  // test controller
  final TextEditingController textController = TextEditingController();

  // open dialog to write notes
  void openNoteBox(String? docID) {
    showDialog(
      context: context, 
      builder: (context) => AlertDialog(
        content: TextField(
          controller: textController,
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              // add a new note
              if (docID == null) {
                firestoreService.addNote(textController.text);
              }
              else {
                firestoreService.updateNote(docID, textController.text);
              }

              //clear the text controller
              textController.clear();

              // close the box
              Navigator.pop(context);
            }, 
            child: (docID == null) ? Text("Add") : Text("Update")
          )
        ],
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:  Center(child: Text("Notes")), 
        backgroundColor: Colors.black, 
        foregroundColor: Colors.white
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => openNoteBox(null),
        child: const Icon(Icons.add)
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getNotesStream(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List notesList = snapshot.data!.docs;

            // display list
            return ListView.builder(
              itemCount: notesList.length,
              itemBuilder: (context, index) {
                // get individual doc
                DocumentSnapshot document = notesList[index];
                String docID = document.id;

                // get note from each doc
                Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                String noteText = data['note'];
                Timestamp timestamp = data['timestamp'];

                

return Container(
  margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.08),
        blurRadius: 8,
        offset: const Offset(0, 4),
      ),
    ],
  ),
  child: Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // --- TESTO NOTA + TIMESTAMP ---
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              noteText,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              // formatta il timestamp (Firestore → DateTime)
              DateFormat('dd/MM/yyyy HH:mm').format(
                (timestamp as Timestamp).toDate(),
              ),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),

      // --- ICONCINE ---
      Row(
        children: [
          IconButton(
            onPressed: () => openNoteBox(docID),
            icon: const Icon(Icons.settings, color: Colors.black87),
            tooltip: 'Modifica nota',
          ),
          IconButton(
            onPressed: () => firestoreService.deleteNote(docID),
            icon: const Icon(Icons.delete, color: Colors.redAccent),
            tooltip: 'Elimina nota',
          ),
        ],
      ),
    ],
  ),
);


              }
            );
          }
          else {
            return Center(child: const Text("No notes"));
          }
        },
      ),
    );
  }
}