import "package:flutter/material.dart";
import 'package:note_that/pages/noteEditor/widgets/noteDataDisplay/noteAudio.dart';
import 'package:note_that/pages/noteEditor/widgets/noteDataDisplay/noteImage.dart';
import 'package:note_that/pages/noteEditor/widgets/noteDataDisplay/noteText.dart';
import 'package:note_that/pages/noteEditor/widgets/noteDataDisplay/noteUrl.dart';
import 'package:note_that/pages/noteEditor/widgets/noteDataDisplay/noteVideo.dart';
import 'package:note_that/stores/selectedNoteStore.dart';
import 'package:note_that/widgets/snackbars.dart';
import 'package:provider/provider.dart';

class NoteWidgetsList extends StatefulWidget {
  const NoteWidgetsList({Key? key}) : super(key: key);

  @override
  State<NoteWidgetsList> createState() => _NoteWidgetsListState();
}

class _NoteWidgetsListState extends State<NoteWidgetsList> {
  int prevLenOfList = 0;
  Key prevKeyOfList = UniqueKey();

  Future<void> removeIndividualData(NoteData noteSelected, int index) async {
    try {
      await noteSelected.removeIndividualData(index: index + 1);
    } catch (e) {
      SnackBars.showErrorMessage(context, "Could not delete the media");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NoteData>(builder: (context, noteSelected, child) {
      Key listKey;

      if (noteSelected.getBodyData().length == prevLenOfList) {
        // If `build` is not invoked for deletion
        listKey = prevKeyOfList;
      } else {
        // If `build` is invoked for deletion
        listKey = UniqueKey();
        prevKeyOfList = listKey;
        prevLenOfList = noteSelected.getBodyData().length;
      }

      return noteSelected.getBodyData().isEmpty
          ? const SizedBox()
          : Expanded(
              child: ListView.builder(
              key: listKey,
              itemCount: noteSelected.getBodyData().length - 1,
              itemBuilder: (context, index) {
                NoteIndividualData individualData =
                    noteSelected.getBodyData()[index + 1];

                return () {
                  // For text
                  if (individualData.getType() == NoteIndividualDataType.text) {
                    return NoteText(
                      initialValue: (individualData as TextData).getText(),
                      onChanged: (val) {
                        noteSelected.setIndividualData(
                            index: index + 1,
                            newNoteIndividualData: val,
                            type: NoteIndividualDataType.text);
                      },
                      onDelete: () {
                        removeIndividualData(noteSelected, index);
                      },
                    );
                  }
                  // For image
                  else if (individualData.getType() ==
                      NoteIndividualDataType.image) {
                    return NoteImage(
                      imageData: individualData as ImageData,
                      onDelete: () {
                        removeIndividualData(noteSelected, index);
                      },
                    );
                  }
                  // For video
                  else if (individualData.getType() ==
                      NoteIndividualDataType.video) {
                    return NoteVideo(
                        videoData: individualData as VideoData,
                        onDelete: () {
                          removeIndividualData(noteSelected, index);
                        });
                  }

                  // For audio
                  else if (individualData.getType() ==
                      NoteIndividualDataType.audio) {
                    return NoteAudio(
                        audioData: individualData as AudioData,
                        onDelete: () {
                          removeIndividualData(noteSelected, index);
                        });
                  }

                  // For url
                  else if (individualData.getType() ==
                      NoteIndividualDataType.url) {
                    return NoteUrl(
                        urlData: individualData as UrlData,
                        onChange: (val) {
                          noteSelected.setIndividualData(
                              index: index + 1,
                              newNoteIndividualData: val,
                              type: NoteIndividualDataType.url);
                        },
                        onDelete: () {
                          removeIndividualData(noteSelected, index);
                        });
                  } else {
                    // For unsupported data
                    return const SizedBox();
                  }
                }();
              },
            ));
    });
  }
}
