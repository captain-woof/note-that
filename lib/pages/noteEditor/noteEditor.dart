import 'package:flutter/material.dart';
import 'package:note_that/pages/noteEditor/widgets/noteDataDisplay/noteTitle.dart';
import 'package:note_that/pages/noteEditor/widgets/actions/noteWidgetAdder.dart';
import 'package:note_that/pages/noteEditor/widgets/noteDataDisplay/noteWidgetsList.dart';
import 'package:note_that/stores/notesStore.dart';
import 'package:note_that/stores/selectedNoteStore.dart';
import 'package:provider/provider.dart';

class NoteEditor extends StatelessWidget {
  const NoteEditor({Key? key}) : super(key: key);

  Future<void> handleSaveNote(BuildContext context, NotesStore notesStore,
      NoteData noteSelected) async {
    // Save as an updated noted, because coming to this screen implies that a new note has already been created and saved to database
    notesStore.updateNote(noteUpdated: noteSelected).then((_) {
      noteSelected.blankOut();
      notesStore.updateAllNotesStored().then((_) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
            Icon(Icons.check, color: Colors.white),
            SizedBox(width: 8),
            Text("Note saved."),
          ],
        )));
        Navigator.of(context).pop();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<NotesStore, NoteData>(
      builder: (context, notesStore, selectedNote, child) {
        return WillPopScope(
          onWillPop: () async {
            await handleSaveNote(context, notesStore, selectedNote);
            return false;
          },
          child: Scaffold(
            appBar: AppBar(
              title: const Text("Write a note"), // Displays title
            ),
            floatingActionButton: FloatingActionButton(
                onPressed: () {
                  handleSaveNote(context, notesStore,
                      selectedNote); // Invokes function to save note
                },
                child: const Icon(Icons.check, semanticLabel: "Save note")),
            body: Container(
              padding: const EdgeInsets.all(24),
              child: Column(children: const [
                NoteTitle(), // Title of the note
                NoteWidgetsList(), // List of all individual note widgets + note widget adder
                NoteWidgetAdder() // Adds note widgets
              ]),
            ),
          ),
        );
      },
    );
  }
}
