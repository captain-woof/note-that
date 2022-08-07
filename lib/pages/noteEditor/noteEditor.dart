import 'package:flutter/material.dart';
import 'package:note_that/pages/noteEditor/widgets/noteDataDisplay/noteTitle.dart';
import 'package:note_that/pages/noteEditor/widgets/actions/noteWidgetAdder.dart';
import 'package:note_that/pages/noteEditor/widgets/noteDataDisplay/noteWidgetsList.dart';
import 'package:note_that/stores/notesStore.dart';
import 'package:note_that/stores/selectedNoteStore.dart';
import 'package:note_that/utils/note_context_drawer.dart';
import 'package:note_that/widgets/snackbars.dart';
import 'package:provider/provider.dart';

class NoteEditor extends StatelessWidget {
  const NoteEditor({Key? key}) : super(key: key);

  Future<void> handleSaveAndCloseNote(BuildContext context,
      NotesStore notesStore, NoteData noteSelected, bool shouldPopRoute) async {
    // Save as an updated noted, because coming to this screen implies that a new note has already been created and saved to database
    try {
      await notesStore.updateNote(noteUpdated: noteSelected);
      noteSelected.blankOut();
      notesStore.updateAllNotesStored().then((_) {
        SnackBars.showInfoMessage(context, "Note saved.");
        if (shouldPopRoute) {
          Navigator.of(context).pop();
        }
      });
    } catch (e) {
      SnackBars.showErrorMessage(context, "Could not save.");
    }
  }

  void handleDeleteNote(
      BuildContext context, NotesStore notesStore, NoteData noteSelected) {
    notesStore.deleteNote(noteToDelete: noteSelected).then((_) {
      SnackBars.showInfoMessage(context, "Note deleted");
      Navigator.of(context).pop();
      Navigator.of(context).pop();
    }).onError((error, stackTrace) {
      SnackBars.showErrorMessage(context, "Note could not be deleted");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<NotesStore, NoteData>(
      builder: (context, notesStore, noteSelected, child) {
        return WillPopScope(
          onWillPop: () async {
            await handleSaveAndCloseNote(
                context, notesStore, noteSelected, false);
            return true;
          },
          child: Scaffold(
            appBar: AppBar(
              title: const Text("Write a note"), // Displays title
              actions: [
                IconButton(
                    onPressed: () {
                      NoteContextDrawer.showNoteContextDrawer(
                          context: context,
                          isNoteOpened: true,
                          handleDeleteNote: () {
                            handleDeleteNote(context, notesStore, noteSelected);
                          },
                          handleCloseNote: () async {
                            Navigator.of(context).pop();
                            await handleSaveAndCloseNote(
                                context, notesStore, noteSelected, true);
                          });
                    },
                    icon: Icon(
                      Icons.more_vert_sharp,
                      size: 28,
                      color: Theme.of(context).primaryColor,
                    ))
              ],
            ),
            floatingActionButton: FloatingActionButton(
                onPressed: () async {
                  await handleSaveAndCloseNote(
                      context, notesStore, noteSelected, true);
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
