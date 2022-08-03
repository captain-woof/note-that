import "package:flutter/material.dart";
import 'package:note_that/stores/selectedNoteStore.dart';
import 'package:note_that/widgets/audioPlayer.dart';
import 'package:note_that/widgets/imageViewer.dart';
import 'package:note_that/widgets/videoPlayer.dart';
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
