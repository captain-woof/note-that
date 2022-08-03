import 'package:flutter/material.dart';
import 'package:note_that/stores/selectedNoteStore.dart';
import 'package:note_that/widgets/imageViewer.dart';

class NoteImage extends StatelessWidget {
  final ImageData imageData;
  final Function() onDelete;

  const NoteImage({Key? key, required this.imageData, required this.onDelete})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ImageViewer(imgFile: imageData.getImageFile()),
        IconButton(
          onPressed: onDelete,
          icon: const Icon(Icons.cancel_outlined, color: Colors.redAccent),
          iconSize: 20,
        )
      ],
    );
  }
}
