import "package:flutter/material.dart";
import 'package:note_that/stores/notesStore.dart';
import 'package:note_that/stores/selectedNoteStore.dart';
import 'package:provider/provider.dart';

class NoteBox extends StatelessWidget {
  final TextEditingController searchTextController;
  final NoteData note;

  const NoteBox(
      {Key? key, required this.searchTextController, required this.note})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    NoteIndividualData summaryIndividualData = note.getBodyData().length == 1
        ? TextData(text: "Nothing in this note yet.")
        : note.getBodyData()[1];
    String title = note.getBodyData()[0].getDisplayData() == ""
        ? "No title"
        : note.getBodyData()[0].getDisplayData();

    return Consumer<NoteData>(builder: (context, noteSelected, child) {
      return Card(
        elevation: 2,
        child: InkWell(
          onTap: () {
            noteSelected.setId(note.getId() as int);
            noteSelected.setBodyData(note.getBodyData());
            searchTextController.text = "";
            Navigator.pushNamed(context, "/note_editor");
          },
          splashColor: Theme.of(context).colorScheme.primary.withAlpha(125),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  // Title of the note
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 2),
                Expanded(
                    // Summary of the note (first inidividual data)
                    child: summaryIndividualData.getType() == "text"
                        ? Text(summaryIndividualData.getDisplayData(),
                            overflow: TextOverflow.fade,
                            style: Theme.of(context).textTheme.bodySmall)
                        : (summaryIndividualData.getType() == "image"
                            ? Image.file(summaryIndividualData.getDisplayData())
                            : const SizedBox()))
              ],
            ),
          ),
        ),
      );
    });
  }
}
