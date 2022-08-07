import "package:flutter/material.dart";

class NoteContextDrawer {
  static void showNoteContextDrawer(
      {required BuildContext context,
      Function()? handleOpenNote,
      Function()? handleCloseNote,
      required Function() handleDeleteNote,
      bool isNoteOpened = false}) {
    showModalBottomSheet(
        context: context,
        backgroundColor: Colors.grey[50],
        enableDrag: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (context) {
          return Container(
            padding: const EdgeInsets.all(20),
            child: Wrap(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Open/close note button
                    NoteContextDrawerButton(
                      buttonStyle: ButtonStyle(
                        overlayColor: MaterialStateColor.resolveWith((states) =>
                            Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.1)),
                      ),
                      onPressed: () {
                        if (isNoteOpened) {
                          // If note is open, close it
                          handleCloseNote!();
                        } else {
                          // If note is not open, open it
                          handleOpenNote!();
                        }
                      },
                      textInButton: isNoteOpened ? "Save and close" : "Open",
                    ),

                    // Delete note button
                    const SizedBox(height: 4),
                    NoteContextDrawerButton(
                      onPressed: handleDeleteNote,
                      textInButton: "Delete",
                      buttonStyle: ButtonStyle(
                        backgroundColor: MaterialStateColor.resolveWith(
                            (states) => Colors.red),
                        overlayColor: MaterialStateColor.resolveWith(
                            (states) => Colors.white.withOpacity(0.1)),
                      ),
                      //TextButton.styleFrom(backgroundColor: Colors.red),
                      textStyleToMerge: const TextStyle(color: Colors.white),
                    ),
                  ],
                )
              ],
            ),
          );
        });
  }
}

class NoteContextDrawerButton extends StatelessWidget {
  final Function()? onPressed;
  final String textInButton;
  final TextStyle? textStyleToMerge;
  final ButtonStyle? buttonStyle;

  const NoteContextDrawerButton(
      {Key? key,
      this.onPressed,
      required this.textInButton,
      this.textStyleToMerge,
      this.buttonStyle})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: buttonStyle,
      child: Text(textInButton,
          style:
              Theme.of(context).textTheme.bodyMedium?.merge(textStyleToMerge)),
    );
  }
}
