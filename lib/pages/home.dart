import "package:flutter/material.dart";
import 'package:note_that/providers/note.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Note> notesFiltered = [];
  TextEditingController searchTextController = TextEditingController(text: "");

  Future<void> handleSearch(
      NoteProvider noteProvider, String searchTerm) async {
    List<Note> newNotesToDisplay =
        await noteProvider.getNotes(searchTerm == "" ? null : searchTerm);

    if (newNotesToDisplay.length != notesFiltered.length) {
      setState(() {
        notesFiltered = newNotesToDisplay;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NoteProvider>(builder: (context, noteProvider, child) {
      return Scaffold(
          appBar: AppBar(title: const Text("NoteThat")),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.pushNamed(context, "/note_editor", arguments: null);
            },
            backgroundColor: Theme.of(context).colorScheme.primary,
            tooltip: "Add a note",
            child: const Icon(Icons.add, semanticLabel: "Add a note"),
          ),
          body: Container(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 0),
                  child: TextField(
                    controller: searchTextController,
                    onChanged: (searchTerm) {
                      handleSearch(noteProvider, searchTerm);
                    },
                    decoration: const InputDecoration(
                        hintText: "Search...", prefixIcon: Icon(Icons.search)),
                  ),
                ),
                const SizedBox(height: 24),
                Expanded(
                    child: GridView.count(crossAxisCount: 2, children: [
                  ...(searchTextController.text == ""
                          ? noteProvider.notesStored
                          : notesFiltered)
                      .map((note) {
                    String title = note.title;
                    String body = note.body;
                    return Card(
                      elevation: 2,
                      child: InkWell(
                        onTap: () {
                          searchTextController.text = "";
                          Navigator.pushNamed(context, "/note_editor",
                              arguments: note);
                        },
                        splashColor: Theme.of(context)
                            .colorScheme
                            .primary
                            .withAlpha(125),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 8),
                              Expanded(
                                  child: Text(
                                      body.length < 100
                                          ? body
                                          : "${body.substring(0, 100)}...",
                                      overflow: TextOverflow.fade,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium))
                            ],
                          ),
                        ),
                      ),
                    );
                  })
                ]))
              ],
            ),
          ));
    });
  }
}
