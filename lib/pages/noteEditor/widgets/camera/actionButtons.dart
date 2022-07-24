import "package:flutter/material.dart";
import 'package:note_that/pages/noteEditor/widgets/camera/camera.dart';

class CameraActionButtons extends StatefulWidget {
  final CameraType cameraType;
  final Future<void> Function() switchCameraLensDirection;
  final bool canFlipCameraLensDirection;
  final CameraCaptureState cameraCaptureState;
  final Function() takePicture;
  final Function() savePicture;
  final Function() recordVideo;
  final Function() stopVideo;
  final Function() pauseVideo;
  final Function() resumeVideo;
  final Function() saveVideo;

  const CameraActionButtons(
      {Key? key,
      required this.cameraType,
      required this.switchCameraLensDirection,
      required this.canFlipCameraLensDirection,
      required this.cameraCaptureState,
      required this.takePicture,
      required this.savePicture,
      required this.pauseVideo,
      required this.resumeVideo,
      required this.recordVideo,
      required this.stopVideo,
      required this.saveVideo})
      : super(key: key);

  @override
  State<CameraActionButtons> createState() => _CameraActionButtonsState();
}

class _CameraActionButtonsState extends State<CameraActionButtons> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Image mode

          //// Image mode - standby
          ...(widget.cameraType == CameraType.image &&
                  widget.cameraCaptureState == CameraCaptureState.standby)
              ? [
                  // Flip camera button
                  CameraActionButtonIcon(
                    icon: Icons.flip_camera_android_outlined,
                    onPressed: widget.canFlipCameraLensDirection
                        ? widget.switchCameraLensDirection
                        : null,
                    semanticLabel: "Flip camera",
                  ),
                  const SizedBox(width: 16),

                  // Capture button
                  CameraActionButtonIcon(
                    icon: Icons.circle_outlined,
                    onPressed: widget.takePicture,
                    semanticLabel: "Capture image",
                    size: 64,
                  ),
                  const SizedBox(width: 16),

                  // Cancel button
                  CameraActionButtonIcon(
                    icon: Icons.cancel_outlined,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    semanticLabel: "Cancel",
                  )
                ]
              : [],

          //// Image mode - finished
          ...(widget.cameraType == CameraType.image &&
                  widget.cameraCaptureState == CameraCaptureState.finished)
              ? [
                  // Cancel button
                  CameraActionButtonIcon(
                    icon: Icons.cancel_outlined,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    semanticLabel: "Cancel",
                  ),
                  const SizedBox(width: 16),
                  // OK button
                  CameraActionButtonIcon(
                    icon: Icons.check,
                    onPressed: widget.savePicture,
                    semanticLabel: "Save photo",
                  )
                ]
              : [],

          // Video mode

          //// Video mode - standby
          ...(widget.cameraType == CameraType.video &&
                  widget.cameraCaptureState == CameraCaptureState.standby)
              ? [
                  // Flip camera button
                  CameraActionButtonIcon(
                    icon: Icons.flip_camera_android_outlined,
                    onPressed: widget.canFlipCameraLensDirection
                        ? widget.switchCameraLensDirection
                        : null,
                    semanticLabel: "Flip lens",
                  ),
                  const SizedBox(width: 16),

                  // Record button
                  CameraActionButtonIcon(
                    icon: Icons.circle_outlined,
                    onPressed: widget.recordVideo,
                    semanticLabel: "Start recording video",
                    size: 64,
                  ),
                  const SizedBox(width: 16),

                  // Cancel button
                  CameraActionButtonIcon(
                    icon: Icons.cancel_outlined,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    semanticLabel: "Cancel",
                  )
                ]
              : [],

          //// Video mode - operating/paused
          ...(widget.cameraType == CameraType.video &&
                  (widget.cameraCaptureState == CameraCaptureState.operating ||
                      widget.cameraCaptureState == CameraCaptureState.paused))
              ? [
                  // Pause button
                  if (widget.cameraCaptureState == CameraCaptureState.operating)
                    CameraActionButtonIcon(
                      icon: Icons.pause,
                      onPressed: widget.pauseVideo,
                      semanticLabel: "Pause recording",
                    ),

                  // Resume button
                  if (widget.cameraCaptureState == CameraCaptureState.paused)
                    CameraActionButtonIcon(
                      icon: Icons.play_arrow,
                      onPressed: widget.resumeVideo,
                      semanticLabel: "Resume recording",
                    ),
                  const SizedBox(width: 16),

                  // Stop button
                  CameraActionButtonIcon(
                    icon: Icons.circle_outlined,
                    onPressed: widget.stopVideo,
                    semanticLabel: "Stop recording",
                    size: 64,
                    color: widget.cameraCaptureState ==
                            CameraCaptureState.operating
                        ? Colors.red[400]
                        : Colors.white,
                  ),
                  const SizedBox(width: 16),

                  // Cancel button
                  const CameraActionButtonIcon(
                    icon: Icons.cancel_outlined,
                    onPressed: null,
                    semanticLabel: "Cancel",
                  )
                ]
              : [],

          //// Video mode - finished
          ...(widget.cameraType == CameraType.video &&
                  widget.cameraCaptureState == CameraCaptureState.finished)
              ? [
                  // Cancel button
                  CameraActionButtonIcon(
                    icon: Icons.cancel_outlined,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    semanticLabel: "Cancel",
                  ),
                  const SizedBox(width: 16),
                  // OK button
                  CameraActionButtonIcon(
                    icon: Icons.check,
                    onPressed: widget.saveVideo,
                    semanticLabel: "Save video",
                  )
                ]
              : [],
        ],
      ),
    );
  }
}

class CameraActionButtonIcon extends StatelessWidget {
  final IconData icon;
  final Function()? onPressed;
  final String semanticLabel;
  final double size;
  final Color? color;

  const CameraActionButtonIcon(
      {Key? key,
      required this.icon,
      required this.onPressed,
      required this.semanticLabel,
      this.color = Colors.white,
      this.size = 40})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
        onPressed: onPressed,
        iconSize: size,
        highlightColor: Theme.of(context).colorScheme.primary,
        color: color,
        splashColor: Colors.white,
        disabledColor: color?.withAlpha(50),
        icon: Icon(
          icon,
          semanticLabel: semanticLabel,
        ));
  }
}
