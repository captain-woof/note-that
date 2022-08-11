import "package:flutter/material.dart";
import 'package:note_that/pages/webView/webView.dart';

class HomeContextDrawer {
  static void showNoteContextDrawer({required BuildContext context}) {
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
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Donate button
                    NoteContextDrawerButton(
                      onPressed: () {
                        WebView.openWebView(
                            context, "https://pages.razorpay.com/sohailsaha");
                      },
                      textInButton: "Donate",
                      iconData: Icons.favorite_border,
                    ),

                    // Author button
                    const SizedBox(height: 4),
                    NoteContextDrawerButton(
                      onPressed: () {
                        WebView.openWebView(context, "https://sohail-saha.in/");
                      },
                      textInButton: "About the author",
                      iconData: Icons.code,
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
  final IconData? iconData;

  const NoteContextDrawerButton(
      {Key? key,
      this.onPressed,
      required this.textInButton,
      this.textStyleToMerge,
      this.buttonStyle,
      this.iconData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (iconData == null) {
      return TextButton(
        onPressed: onPressed,
        style: buttonStyle == null
            ? const ButtonStyle(alignment: Alignment.centerLeft)
            : buttonStyle
                ?.merge(const ButtonStyle(alignment: Alignment.centerLeft)),
        child: Text(textInButton,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.merge(textStyleToMerge)),
      );
    } else {
      return TextButton.icon(
        icon: Icon(iconData),
        onPressed: onPressed,
        style: buttonStyle == null
            ? const ButtonStyle(alignment: Alignment.centerLeft)
            : buttonStyle
                ?.merge(const ButtonStyle(alignment: Alignment.centerLeft)),
        label: Text(textInButton,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.merge(textStyleToMerge)),
      );
    }
  }
}
