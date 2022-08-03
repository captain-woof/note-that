import 'package:flutter/material.dart';
import 'package:note_that/pages/noteEditor/widgets/noteDataDisplay/noteTitle.dart';
import 'package:note_that/pages/noteEditor/widgets/actions/noteWidgetAdder.dart';
import 'package:note_that/pages/noteEditor/widgets/noteDataDisplay/noteWidgetsList.dart';
import 'package:note_that/stores/notesStore.dart';
import 'package:note_that/stores/selectedNoteStore.dart';
import 'package:note_that/widgets/snackbars.dart';
import 'package:provider/provider.dart';

class NoteEditor extends StatelessWidget {
  const NoteEditor({Key? key}) : super(key: key);

  Future<void> handleSaveNote(BuildContext context, NotesStore notesStore,
      NoteData noteSelected) async {
    // Save as an updated noted, because coming to this screen implies that a new note has already been created and saved to database
    try {
      await notesStore.updateNote(noteUpdated: noteSelected);
      noteSelected.blankOut();
      notesStore.updateAllNotesStored().then((_) {
        SnackBars.showInfoMessage(context, "Note saved.");
        Navigator.of(context).pop();
      });
    } catch (e) {
      SnackBars.showErrorMessage(context, "Could not save.");
    }
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
