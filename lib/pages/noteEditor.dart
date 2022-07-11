import 'package:flutter/material.dart';
import 'package:note_that/providers/note.dart';
import 'package:provider/provider.dart';

class NoteEditor extends StatefulWidget {
  const NoteEditor({Key? key}) : super(key: key);

  @override
  State<NoteEditor> createState() => _NoteEditorState();
}

class _NoteEditorState extends State<NoteEditor> {
  @override
  Widget build(BuildContext context) {
    Note? noteExisting = ModalRoute.of(context)?.settings.arguments as Note?;

    final TextEditingController titleController =
        TextEditingController(text: noteExisting?.title ?? "");
    final TextEditingController bodyController =
        TextEditingController(text: noteExisting?.body ?? "");

    void handleSaveNote(NoteProvider noteProvider) {
      final Note noteToSave = Note(
          id: noteExisting?.id ?? noteProvider.notesStored.length,
          body: bodyController.text,
          title: titleController.text);
      if (noteExisting == null) {
        noteProvider.addNote(noteNew: noteToSave).then((_) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text("Note saved.")));
          Navigator.of(context).pop();
        });
      } else {
        noteProvider.updateNote(noteUpdated: noteToSave).then((_) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text("Note saved.")));
          Navigator.of(context).pop();
        });
      }
    }

    return Consumer<NoteProvider>(
      builder: (context, noteProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(noteExisting != null ? "Edit note" : "Add note"),
          ),
          floatingActionButton: FloatingActionButton(
              onPressed: () {
                handleSaveNote(noteProvider);
              },
              child: const Icon(Icons.check, semanticLabel: "Save note")),
          body: Container(
            padding: const EdgeInsets.all(24),
            child: Column(children: [
              TextField(
                controller: titleController,
                style: Theme.of(context).textTheme.titleLarge,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "Title",
                ),
              ),
              Expanded(
                  child: TextField(
                controller: bodyController,
                style: Theme.of(context).textTheme.bodyMedium,
                expands: true,
                minLines: null,
                maxLines: null,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: "Start typing...",
                ),
              )),
            ]),
          ),
        );
      },
    );
  }
}
