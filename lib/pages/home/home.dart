import "package:flutter/material.dart";
import 'package:note_that/pages/home/widgets/notesStoredGrid.dart';
import 'package:note_that/stores/notesStore.dart';
import 'package:note_that/stores/selectedNoteStore.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<NoteData> notesFiltered = [];
  TextEditingController searchTextController = TextEditingController(text: "");

  Future<void> handleSearch(NotesStore notesStore, String searchTerm) async {
    List<NoteData> newNotesToDisplay = notesStore.getNotes(searchTerm);

    setState(() {
      notesFiltered = newNotesToDisplay;
    });
  }

  void handleCreateNewNote(NotesStore notesStore, NoteData selectedNote) {
    selectedNote.blankOut();
    selectedNote.setId(notesStore.getNewNoteId());
    notesStore.addNote(noteNew: selectedNote).then((_) {
      Navigator.pushNamed(context, "/note_editor");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<NotesStore, NoteData>(
        builder: (context, notesStore, selectedNote, child) {
      return Scaffold(
          appBar: AppBar(title: const Text("NoteThat")),
          floatingActionButton: FloatingActionButton(
            // Creates a new post and opens editor
            onPressed: () {
              handleCreateNewNote(notesStore, selectedNote);
            },
            backgroundColor: Theme.of(context).colorScheme.primary,
            tooltip: "Add a note",
            child: const Icon(Icons.add, semanticLabel: "Add a note"),
          ),
          body: Container(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: Column(
              children: [
                TextField(
                  // Search bar
                  controller: searchTextController,
                  onChanged: (searchTerm) {
                    handleSearch(notesStore, searchTerm);
                  },
                  style: Theme.of(context).textTheme.titleSmall,
                  decoration: const InputDecoration(
                      hintText: "Search...",
                      prefixIcon: Icon(Icons.search),
                      contentPadding: EdgeInsets.all(0),
                      border: OutlineInputBorder(borderSide: BorderSide())),
                ),
                const SizedBox(height: 24),
                NotesStoredGrid(
                    // Notes stored
                    searchTextController: searchTextController,
                    notesFiltered: notesFiltered)
              ],
            ),
          ));
    });
  }
}
