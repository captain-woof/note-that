import 'dart:io';
import 'package:note_that/stores/selectedNoteStore.dart';
import 'package:note_that/widgets/snackbars.dart';
import 'package:note_that/widgets/videoPlayer.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:note_that/pages/noteEditor/widgets/camera/actionButtons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:device_info_plus/device_info_plus.dart';

enum CameraType { image, video }

enum CameraCaptureState { standby, operating, paused, finished }

class Camera extends StatefulWidget {
  final CameraType mode; // "image" or "video"

  const Camera({Key? key, this.mode = CameraType.image}) : super(key: key);

  @override
  State<Camera> createState() => _CameraState();
}

class _CameraState extends State<Camera> {
  late List<CameraDescription> _cameraDescriptions;
  late CameraController _cameraController;
  Future<void>? _cameraInitializerFuture;
  int cameraLensSelectedIndex = 0;
  late CameraCaptureState _cameraCaptureState;
  late double scale;
  late XFile _tempFile;
  late bool pauseResumeSupported;

  // Check if multiple (back and front cameras) are available
  bool areMultipleCamerasAvailable() {
    return (_cameraDescriptions.length > 1);
  }

  // Calculate scale to scale up camera preview
  double getCameraScale() =>
      1 /
      (_cameraController.value.aspectRatio *
          MediaQuery.of(context).size.aspectRatio);

  // Function to initialise new camera
  Future<void> initializeCamera(
      {required int cameraLensSelectedIndex,
      bool cleanupNeeded = false}) async {
    try {
      _cameraCaptureState = CameraCaptureState.standby;
      if (cleanupNeeded) {
        await _cameraController.dispose();
      }

      _cameraController = CameraController(
          _cameraDescriptions[cameraLensSelectedIndex], ResolutionPreset.high,
          enableAudio: widget.mode == CameraType.video);

      await _cameraController.initialize();

      scale = getCameraScale();
    } catch (e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            SnackBars.showErrorMessage(
                context, 'Camera access permission denied');
            break;
          case 'CameraAccessDeniedWithoutPrompt':
            SnackBars.showErrorMessage(
                context, 'Please manually enable camera permissions');
            break;
          case 'CameraAccessRestricted':
            SnackBars.showErrorMessage(
                context, 'Need admin to grant camera permission');
            break;
          case 'AudioAccessDenied':
            SnackBars.showErrorMessage(
                context, 'Microphone access permission denied');
            break;
          case 'AudioAccessDeniedWithoutPrompt':
            SnackBars.showErrorMessage(
                context, 'Please manually enable microphone permissions');
            break;
          case 'AudioAccessRestricted':
            SnackBars.showErrorMessage(
                context, 'Need admin to grant microphone permission');
            break;
          default:
            SnackBars.showErrorMessage(context, 'Could not start camera');
            break;
        }
      } else {
        SnackBars.showErrorMessage(context, 'Could not start camera');
      }
      Navigator.of(context).pop();
    }
  }

  // Function to switch between available cameras
  Future<void> switchCameraLensDirection() async {
    cameraLensSelectedIndex =
        (cameraLensSelectedIndex + 1) % _cameraDescriptions.length;
    setState(() {
      _cameraInitializerFuture = initializeCamera(
          cameraLensSelectedIndex: cameraLensSelectedIndex,
          cleanupNeeded: true);
    });
  }

  // Function to take photo
  Future<void> takePicture() async {
    try {
      XFile imgFile = await _cameraController.takePicture();
      setState(() {
        _tempFile = imgFile;
        _cameraCaptureState = CameraCaptureState.finished;
      });
    } catch (e) {
      SnackBars.showErrorMessage(context, "Could not capture image");
    }
  }

  // Function to save a taken photo
  Future<void> savePicture(NoteData noteSelected) async {
    try {
      Directory saveDirectory = await getApplicationDocumentsDirectory();
      String savePath = path.join(saveDirectory.path, _tempFile.name);
      await _tempFile.saveTo(savePath);
      noteSelected.addIndividualData(
          noteIndividualData: savePath, type: NoteIndividualDataType.image);
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      SnackBars.showErrorMessage(context, "Could not save image");
    }
  }

  // Function to start recording video
  Future<void> recordVideo() async {
    try {
      await _cameraController.startVideoRecording();
      setState(() {
        _cameraCaptureState = CameraCaptureState.operating;
      });
    } catch (e) {
      SnackBars.showErrorMessage(context, "Could not start recording");
    }
  }

  // Function to pause recording video
  Future<void> pauseVideo() async {
    try {
      await _cameraController.pauseVideoRecording();
      setState(() {
        _cameraCaptureState = CameraCaptureState.paused;
      });
    } catch (e) {
      SnackBars.showErrorMessage(context, "Cannot pause recording");
    }
  }

  // Function to resume recording video
  Future<void> resumeVideo() async {
    try {
      await _cameraController.resumeVideoRecording();
      setState(() {
        _cameraCaptureState = CameraCaptureState.operating;
      });
    } catch (e) {
      SnackBars.showErrorMessage(context, "Cannot resume recording");
    }
  }

  // Function to stop recording video
  Future<void> stopVideo() async {
    try {
      XFile videoRecorded = await _cameraController.stopVideoRecording();
      setState(() {
        _cameraCaptureState = CameraCaptureState.finished;
        _tempFile = videoRecorded;
      });
    } catch (e) {
      SnackBars.showErrorMessage(context, "Cannot stop recording");
      if (!mounted) return;
      Navigator.of(context).pop();
    }
  }

  // Function to save recording video
  Future<void> saveVideo(NoteData noteSelected) async {
    try {
      Directory saveDirectory = await getApplicationDocumentsDirectory();
      String savePath = path.join(saveDirectory.path, _tempFile.name);
      await _tempFile.saveTo(savePath);
      noteSelected.addIndividualData(
          noteIndividualData: savePath, type: NoteIndividualDataType.video);
    } catch (e) {
      SnackBars.showErrorMessage(context, "Could not save video");
    } finally {
      Navigator.of(context).pop();
    }
  }

  // Function to get if pause/resume recording video is supported
  Future<bool> getPlatformSupportPauseResume() async {
    DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    var androidDeviceInfo = await deviceInfoPlugin.androidInfo;

    // If android, check if API is at least 24
    if (androidDeviceInfo.version.sdkInt != null) {
      return androidDeviceInfo.version.sdkInt! >= 24;
    }

    // If any other platform, no check required
    else {
      return true;
    }
  }

  @override
  void initState() {
    super.initState();
    _cameraCaptureState = CameraCaptureState.standby;
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

    _cameraInitializerFuture = availableCameras().then((cameras) async {
      // Get camera info
      _cameraDescriptions = cameras;

      // Initialise with first camera info
      await initializeCamera(cameraLensSelectedIndex: 0);

      // Get if pause/resume is supported
      pauseResumeSupported = await getPlatformSupportPauseResume();
    });
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _cameraController.dispose();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NoteData>(builder: (context, noteSelected, child) {
      return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: Text(widget.mode == CameraType.image
              ? "Take an image"
              : "Take a video"),
          centerTitle: true,
          titleTextStyle: TextStyle(
              color: Colors.white,
              fontFamily:
                  Theme.of(context).appBarTheme.titleTextStyle?.fontFamily,
              fontSize: Theme.of(context).appBarTheme.titleTextStyle?.fontSize,
              fontWeight:
                  Theme.of(context).appBarTheme.titleTextStyle?.fontWeight),
          actionsIconTheme: const IconThemeData(color: Colors.white),
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        body: FutureBuilder<void>(
          initialData: null,
          future: _cameraInitializerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              // Display camera if ready.
              return Stack(
                children: [
                  // Camera/Camcorder live feed
                  if (_cameraCaptureState != CameraCaptureState.finished)
                    Transform.scale(
                      scale: scale,
                      alignment: Alignment.topCenter,
                      child: CameraPreview(
                        _cameraController,
                      ),
                    ),

                  // Image taken preview
                  if (widget.mode == CameraType.image &&
                      _cameraCaptureState == CameraCaptureState.finished)
                    Transform.scale(
                      scale: scale,
                      alignment: Alignment.topCenter,
                      child: Image.file(File(_tempFile.path)),
                    ),

                  // Video captured preview
                  if (widget.mode == CameraType.video &&
                      _cameraCaptureState == CameraCaptureState.finished)
                    Transform.scale(
                      scale: scale,
                      alignment: Alignment.topCenter,
                      child: VideoPlayer.fromFile(
                        videoFile: File(_tempFile.path),
                        loop: true,
                        autoPlay: true,
                      ),
                    ),

                  // Camera Action buttons
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: CameraActionButtons(
                      cameraType: widget.mode,
                      cameraCaptureState: _cameraCaptureState,
                      switchCameraLensDirection: switchCameraLensDirection,
                      canFlipCameraLensDirection: areMultipleCamerasAvailable(),
                      takePicture: takePicture,
                      savePicture: () {
                        savePicture(noteSelected);
                      },
                      recordVideo: recordVideo,
                      pauseVideo: pauseResumeSupported ? pauseVideo : null,
                      resumeVideo: pauseResumeSupported ? resumeVideo : null,
                      stopVideo: stopVideo,
                      saveVideo: () {
                        saveVideo(noteSelected);
                      },
                    ),
                  )
                ],
              );
            } else {
              // Otherwise, display a loading indicator.
              return Expanded(
                  child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      semanticsLabel:
                          "Opening ${widget.mode == CameraType.image ? 'camera' : 'camcorder'}",
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Opening ${widget.mode == CameraType.image ? 'camera' : 'camcorder'}",
                      style: Theme.of(context).textTheme.bodyMedium,
                    )
                  ],
                ),
              ));
            }
          },
        ),
      );
    });
  }
}
