import "package:flutter/material.dart";
import 'package:note_that/pages/noteEditor/widgets/noteImage.dart';
import 'package:note_that/pages/noteEditor/widgets/noteText.dart';
import 'package:note_that/stores/selectedNoteStore.dart';
import 'package:provider/provider.dart';

class NoteWidgetsList extends StatefulWidget {
  const NoteWidgetsList({Key? key}) : super(key: key);

  @override
  State<NoteWidgetsList> createState() => _NoteWidgetsListState();
}

class _NoteWidgetsListState extends State<NoteWidgetsList> {
  int prevLenOfList = 0;
  Key prevKeyOfList = UniqueKey();

  void removeIndividualData(NoteData noteSelected, int index) {
    noteSelected.removeIndividualData(index: index + 1);
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

      return Expanded(
          child: ListView.builder(
        key: listKey,
        itemCount: noteSelected.getBodyData().length - 1,
        itemBuilder: (context, index) {
          NoteIndividualData individualData =
              noteSelected.getBodyData()[index + 1];

          return () {
            if (individualData.getType() == "text") {
              // For text
              return NoteText(
                initialValue: (individualData as TextData).getText(),
                onChanged: (val) {
                  noteSelected.setIndividualData(
                      index: index + 1,
                      newNoteIndividualData: val,
                      type: "text");
                },
                onDelete: () {
                  removeIndividualData(noteSelected, index);
                },
              );
            } else if (individualData.getType() == "image") {
              // For image
              return NoteImage(
                imageData: individualData as ImageData,
                onDelete: () {
                  removeIndividualData(noteSelected, index);
                },
              );
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
