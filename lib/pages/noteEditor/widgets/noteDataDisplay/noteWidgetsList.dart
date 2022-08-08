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
  ScrollController? _scrollController;
  double _scrollOffset = 0;
  int _numOfWidgets = 0;

  @override
  void dispose() {
    _scrollController?.dispose();
    super.dispose();
  }

  ScrollController _prepareScrollController({double initialScrollOffset = 0}) {
    // Dispose previous controller
    _scrollController?.dispose();
    // Init controller
    _scrollController =
        ScrollController(initialScrollOffset: initialScrollOffset);
    // Attach listener for scroll position
    _scrollController?.addListener(() {
      _scrollOffset = _scrollController?.offset ?? 0;
    });
    return _scrollController as ScrollController;
  }

  Future<void> removeIndividualData(NoteData noteSelected, int index) async {
    try {
      await noteSelected.removeIndividualData(index: index + 1);
    } catch (e) {
      SnackBars.showErrorMessage(context, "Could not delete the media");
    }
  }

  Future<void> _scrollToBottomIfNeeded(NoteData noteSelected) async {
    // ignore: unnecessary_null_comparison
    if (_scrollController != null &&
        (_scrollController as ScrollController).hasClients) {
      try {
        // If this is neither the first widget nor loading for first time
        if (_numOfWidgets != 0) {
          // If a new widget was added
          if (_numOfWidgets < noteSelected.getBodyData().length) {
            // Scroll smoothly all the way down
            await Future.delayed(const Duration(milliseconds: 100), () {
              _scrollController?.jumpTo(_scrollOffset);
              _scrollController?.animateTo(
                  _scrollController?.position.maxScrollExtent ?? 0,
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeInOutCubic);
            });
          }

          // If an existing widget was removed
          else if (_numOfWidgets > noteSelected.getBodyData().length) {
            // DO NOTHING
          }

          // Save new number of widgets
          _numOfWidgets = noteSelected.getBodyData().length;
        }
      } catch (e) {
        // DO NOTHING
      }
    } else {
      _numOfWidgets = noteSelected.getBodyData().length;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NoteData>(builder: (context, noteSelected, child) {
      // Scroll to bottom if num of widgets changed
      _scrollToBottomIfNeeded(noteSelected);

      return noteSelected.getBodyData().isEmpty
          ? const SizedBox()
          : Expanded(
              child: ListView.builder(
              key: Key(noteSelected.getBodyData().length.toString()),
              controller:
                  _prepareScrollController(initialScrollOffset: _scrollOffset),
              itemCount: noteSelected.getBodyData().length - 1,
              itemBuilder: (context, index) {
                // Get the individual data
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
