import "package:flutter/material.dart";
import 'package:note_that/pages/home/widgets/noteBox.dart';
import 'package:note_that/stores/notesStore.dart';
import 'package:note_that/stores/selectedNoteStore.dart';
import "package:provider/provider.dart";

class NotesStoredGrid extends StatelessWidget {
  final TextEditingController searchTextController;
  final List<NoteData> notesFiltered;

  const NotesStoredGrid(
      {Key? key,
      required this.searchTextController,
      required this.notesFiltered})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<NotesStore>(builder: (context, notesStore, child) {
      return Expanded(
          child: GridView.count(
              crossAxisCount: 2,
              children: (searchTextController.text == ""
                      ? notesStore.getNotes(null)
                      : notesFiltered)
                  .map((note) {
                return NoteBox(
                    searchTextController: searchTextController, note: note);
              }).toList()));
    });
  }
}
