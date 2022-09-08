import 'package:flutter/material.dart';
import 'package:note_that/stores/selectedNoteStore.dart';
import 'package:note_that/widgets/imageViewer.dart';

class NoteImage extends StatelessWidget {
  final ImageData imageData;
  final Function() onDelete;
  final Function() onShare;

  const NoteImage(
      {Key? key,
      required this.imageData,
      required this.onDelete,
      required this.onShare})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ImageViewer(imgFile: imageData.getImageFile()),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Share button
            IconButton(
              onPressed: onShare,
              icon: Icon(Icons.share,
                  color: Theme.of(context).colorScheme.primary),
              iconSize: 24,
            ),

            // Delete button
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.cancel_outlined, color: Colors.redAccent),
              iconSize: 24,
            )
          ],
        ),
      ],
    );
  }
}
