import "package:flutter/material.dart";
import 'package:note_that/providers/note.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<NoteProvider>(
        builder: (context, noteProvider, child) => Scaffold(
            appBar: AppBar(title: const Text("NoteThat")),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(context, "/note_editor", arguments: null);
              },
              backgroundColor: Theme.of(context).colorScheme.primary,
              tooltip: "Add a note",
              child: const Icon(Icons.add, semanticLabel: "Add a note"),
            ),
            body: GridView.count(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                crossAxisCount: 2,
                children: List<Card>.generate(noteProvider.notesStored.length,
                    (index) {
                  Note currentNote = noteProvider.notesStored[index];
                  String title = currentNote.title;
                  String body = currentNote.body;

                  return Card(
                    elevation: 2,
                    child: InkWell(
                      onTap: () {
                        Navigator.pushNamed(context, "/note_editor",
                            arguments: currentNote);
                      },
                      splashColor:
                          Theme.of(context).colorScheme.primary.withAlpha(125),
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
                                    style:
                                        Theme.of(context).textTheme.bodyMedium))
                          ],
                        ),
                      ),
                    ),
                  );
                }))));
  }
}
