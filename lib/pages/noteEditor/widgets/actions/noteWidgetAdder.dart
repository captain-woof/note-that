import 'package:flutter/material.dart';
import 'package:note_that/pages/noteEditor/widgets/camera/camera.dart';
import 'package:note_that/stores/selectedNoteStore.dart';
import 'package:provider/provider.dart';

class NoteWidgetAdder extends StatelessWidget {
  const NoteWidgetAdder({Key? key}) : super(key: key);

  void handleShowCamera({required BuildContext context}) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Camera());
  }

  void handleShowCamcorder({required BuildContext context}) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Camera(mode: CameraType.video));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NoteData>(builder: (context, noteSelected, child) {
      return Container(
        margin: const EdgeInsets.only(top: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Add Icon
            const Icon(Icons.add, color: Colors.grey),

            // Text
            _PostWidgetAdderButton(
                onPressed: () {
                  noteSelected.addIndividualData(
                      noteIndividualData: "",
                      type: NoteIndividualDataType.text);
                },
                iconData: Icons.text_fields_sharp),

            // Camera
            _PostWidgetAdderButton(
                onPressed: () {
                  handleShowCamera(context: context);
                },
                iconData: Icons.camera_alt_outlined),

            // Video recorder
            _PostWidgetAdderButton(
                onPressed: () {
                  handleShowCamcorder(context: context);
                },
                iconData: Icons.video_call_outlined),

            // Audio recorder
            _PostWidgetAdderButton(
                onPressed: () {
                  noteSelected.addIndividualData(
                      noteIndividualData: "",
                      type: NoteIndividualDataType.audio);
                },
                iconData: Icons.multitrack_audio_outlined),
          ],
        ),
      );
    });
  }
}

// For buttons used here
class _PostWidgetAdderButton extends StatelessWidget {
  final void Function() onPressed;
  final IconData iconData;

  const _PostWidgetAdderButton(
      {Key? key, required this.onPressed, required this.iconData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(onPressed: onPressed, icon: Icon(iconData));
  }
}
