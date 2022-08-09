import 'package:flutter/material.dart';
import 'package:note_that/stores/selectedNoteStore.dart';
import 'package:note_that/widgets/urlViewer.dart';

class NoteUrl extends StatelessWidget {
  final UrlData urlData;
  final Function() onDelete;
  final Function() onShare;
  final Function(String) onChange;

  const NoteUrl(
      {Key? key,
      required this.onDelete,
      required this.urlData,
      required this.onChange,
      required this.onShare})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        UrlViewer(
          url: urlData.getDisplayData(),
          onChange: onChange,
        ),
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
