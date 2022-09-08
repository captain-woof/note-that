import "package:flutter/material.dart";
import 'package:note_that/stores/notesStore.dart';
import 'package:note_that/stores/selectedNoteStore.dart';
import 'package:note_that/utils/note_context_drawer.dart';
import 'package:note_that/widgets/audioPlayer.dart';
import 'package:note_that/widgets/imageViewer.dart';
import 'package:note_that/widgets/snackbars.dart';
import 'package:note_that/widgets/urlViewer.dart';
import 'package:note_that/widgets/videoPlayer.dart';
import 'package:provider/provider.dart';

class NoteBox extends StatelessWidget {
  final TextEditingController searchTextController;
  final NoteData note;

  const NoteBox(
      {Key? key, required this.searchTextController, required this.note})
      : super(key: key);

  void handleOpenNote(BuildContext context, NoteData noteSelected) {
    noteSelected.setFromNoteData(noteData: note);
    searchTextController.text = "";
    Navigator.pushNamed(context, "/note_editor");
  }

  Future<void> handleDeleteNote(
      BuildContext context, NotesStore notesStore) async {
    try {
      await notesStore.deleteNote(noteToDelete: note).then((_) {
        SnackBars.showInfoMessage(context, "Note deleted");
      });
    } catch (e) {
      SnackBars.showErrorMessage(context, "Note could not be deleted");
    }
  }

  @override
  Widget build(BuildContext context) {
    NoteIndividualData summaryIndividualData = note.getBodyData().length == 1
        ? TextData(text: "Nothing in this note yet.")
        : note.getBodyData()[1];
    String title = note.getBodyData()[0].getDisplayData() == ""
        ? "No title"
        : note.getBodyData()[0].getDisplayData();

    return Consumer2<NotesStore, NoteData>(
        builder: (context, notesStore, noteSelected, child) {
      return Card(
        elevation: 2,
        child: InkWell(
          onTap: () {
            handleOpenNote(context, noteSelected);
          },
          onLongPress: () {
            NoteContextDrawer.showNoteContextDrawer(
                context: context,
                handleDeleteNote: () {
                  Navigator.of(context).pop();
                  handleDeleteNote(context, notesStore);
                },
                handleOpenNote: () {
                  Navigator.of(context).pop();
                  handleOpenNote(context, noteSelected);
                });
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
                const SizedBox(height: 8),
                Expanded(
                    // Summary of the note (first inidividual data)
                    child: () {
                  // For text
                  if (summaryIndividualData.getType() ==
                      NoteIndividualDataType.text) {
                    return Text(summaryIndividualData.getDisplayData(),
                        overflow: TextOverflow.fade,
                        style: Theme.of(context).textTheme.bodySmall);
                  }
                  // For image
                  else if (summaryIndividualData.getType() ==
                      NoteIndividualDataType.image) {
                    return ImageViewer(
                        imgFile: (summaryIndividualData as ImageData)
                            .getImageFile());
                  }
                  // For video
                  else if (summaryIndividualData.getType() ==
                      NoteIndividualDataType.video) {
                    return VideoPlayer(
                        videoData: summaryIndividualData as VideoData,
                        autoPlay: false,
                        loop: true,
                        videoPlayerMode: VideoPlayerMode.withControls);
                  }
                  // For audio
                  else if (summaryIndividualData.getType() ==
                      NoteIndividualDataType.audio) {
                    return AudioPlayer(
                        audioData: summaryIndividualData as AudioData,
                        miniPlayer: true);
                  }

                  // For url
                  else if (summaryIndividualData.getType() ==
                      NoteIndividualDataType.url) {
                    return UrlViewer(
                        url:
                            (summaryIndividualData as UrlData).getDisplayData(),
                        miniViewer: true);
                  }
                  // Fallback
                  else {
                    return const SizedBox();
                  }
                }())
              ],
            ),
          ),
        ),
      );
    });
  }
}
