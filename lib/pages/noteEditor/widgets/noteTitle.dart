import "package:flutter/material.dart";
import 'package:note_that/stores/selectedNoteStore.dart';
import 'package:provider/provider.dart';

class NoteTitle extends StatelessWidget {
  const NoteTitle({Key? key}) : super(key: key);

  void handleTitleChange(NoteData noteSelected, String newTitle) {
    noteSelected.setTitle(newTitle: newTitle);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NoteData>(builder: (context, noteSelected, child) {
      return TextFormField(
        // Title of the post
        initialValue: noteSelected.getBodyData()[0].getDisplayData(),
        onChanged: (val) {
          handleTitleChange(noteSelected, val);
        },
        style: Theme.of(context).textTheme.titleLarge,
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: "Title",
        ),
      );
    });
  }
}
