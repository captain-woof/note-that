import "package:flutter/material.dart";

class NoteText extends StatefulWidget {
  final void Function(String) onChanged;
  final void Function() onDelete;
  final Function() onShare;
  final String initialValue;

  const NoteText(
      {Key? key,
      required this.onChanged,
      required this.onDelete,
      this.initialValue = "",
      required this.onShare})
      : super(key: key);

  @override
  State<NoteText> createState() => _NoteTextState();
}

class _NoteTextState extends State<NoteText> {
  final FocusNode focusNode = FocusNode();
  bool isSelected = false;

  void handleFocusChange() {
    setState(() {
      isSelected = focusNode.hasFocus;
    });
  }

  @override
  void initState() {
    super.initState();
    focusNode.addListener(handleFocusChange);
  }

  @override
  void dispose() {
    super.dispose();
    focusNode.removeListener(handleFocusChange);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Text
        TextFormField(
          initialValue: widget.initialValue,
          style: Theme.of(context).textTheme.bodyMedium,
          minLines: 1,
          maxLines: null,
          decoration: const InputDecoration(
            border: InputBorder.none,
            hintText: "Start typing...",
          ),
          onChanged: widget.onChanged,
          focusNode: focusNode,
        ),

        if (isSelected)
          // Delete button
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Share button
              IconButton(
                onPressed: widget.onShare,
                icon: Icon(Icons.share,
                    color: Theme.of(context).colorScheme.primary),
                iconSize: 24,
              ),

              // Delete button
              IconButton(
                onPressed: widget.onDelete,
                icon:
                    const Icon(Icons.cancel_outlined, color: Colors.redAccent),
                iconSize: 24,
              )
            ],
          ),
      ],
    );
  }
}
