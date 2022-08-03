import 'package:flutter/material.dart';
import 'package:note_that/stores/selectedNoteStore.dart';
import 'package:note_that/widgets/urlViewer.dart';

class NoteUrl extends StatelessWidget {
  final UrlData urlData;
  final Function() onDelete;
  final Function(String) onChange;

  const NoteUrl(
      {Key? key,
      required this.onDelete,
      required this.urlData,
      required this.onChange})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        UrlViewer(
          url: urlData.getDisplayData(),
          onChange: onChange,
        ),
        IconButton(
          onPressed: onDelete,
          icon: const Icon(Icons.cancel_outlined, color: Colors.redAccent),
          iconSize: 20,
        )
      ],
    );
  }
}
