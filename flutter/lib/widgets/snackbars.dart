import 'package:flutter/material.dart';

class SnackBars {
  // Invoke to show error message
  static void showErrorMessage(BuildContext context, String errorMessage) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(errorMessage)),
          ],
        )));
  }

  // Invoke to show info message
  static void showInfoMessage(BuildContext context, String infoMessage) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Icon(Icons.check, color: Colors.white),
        const SizedBox(width: 8),
        Expanded(child: Text(infoMessage)),
      ],
    )));
  }
}
