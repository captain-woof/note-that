import 'dart:io';
import 'package:flutter/material.dart';

class ImageViewer extends StatefulWidget {
  final File imgFile;

  const ImageViewer({Key? key, required this.imgFile}) : super(key: key);

  @override
  State<ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  late bool _error;

  @override
  void initState() {
    super.initState();

    // Check if image file can be opened for viewing
    _error = !widget.imgFile.existsSync();
  }

  @override
  Widget build(BuildContext context) {
    return !_error

        // If no errors, show the image
        ? Image.file(widget.imgFile)

        // If error, show fallback
        : Container(
            decoration: BoxDecoration(color: Colors.grey[600]),
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 16),
            child: Center(
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                runSpacing: 4,
                spacing: 4,
                children: [
                  Text(
                    "Could not load image",
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.merge(const TextStyle(color: Colors.white)),
                  ),
                  const Icon(Icons.error_outline, color: Colors.white, size: 20)
                ],
              ),
            ),
          );
  }
}
