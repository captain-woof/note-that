import 'dart:io';
import 'package:note_that/stores/notesStore.dart';
import 'package:note_that/stores/selectedNoteStore.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:note_that/pages/noteEditor/widgets/camera/actionButtons.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

enum CameraType { image, video }

enum CameraCaptureState { standby, operating, finished }

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
    _cameraCaptureState = CameraCaptureState.standby;
    if (cleanupNeeded) {
      await _cameraController.dispose();
    }

    _cameraController = CameraController(
        _cameraDescriptions[cameraLensSelectedIndex], ResolutionPreset.high,
        enableAudio: widget.mode == CameraType.video);

    await _cameraController.initialize();

    scale = getCameraScale();
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

  // Cleanup for screen and camera
  void cleanup() async {
    await Future.wait([
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
          overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom]),
      _cameraController.dispose()
    ]);
  }

  // Function to take photo
  void takePicture() {
    _cameraController.takePicture().then((file) {
      setState(() {
        _tempFile = file;
        _cameraCaptureState = CameraCaptureState.finished;
      });
    });
  }

  // Function to save a taken photo
  void savePicture(NoteData noteSelected) {
    getApplicationDocumentsDirectory().then((saveDirectory) {
      String savePath = path.join(saveDirectory.path, _tempFile.name);
      _tempFile.saveTo(savePath).then((_) {
        noteSelected.addIndividualData(
            noteIndividualData: savePath, type: NoteIndividualDataType.image);
        Navigator.of(context).pop();
      });
    });
  }

  // Function to save taken photo

  @override
  void initState() {
    super.initState();
    _cameraCaptureState = CameraCaptureState.standby;
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

    _cameraInitializerFuture = availableCameras().then((cameras) async {
      _cameraDescriptions = cameras;
      await initializeCamera(cameraLensSelectedIndex: 0);
    });
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    super.dispose();
    cleanup();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NoteData>(builder: (context, noteSelected, child) {
      return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: const Text("Take an image"),
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
                  // Camera preview
                  if (_cameraCaptureState == CameraCaptureState.standby)
                    Transform.scale(
                      scale: scale,
                      alignment: Alignment.topCenter,
                      child: CameraPreview(
                        _cameraController,
                      ),
                    ),

                  if (_cameraCaptureState == CameraCaptureState.finished)
                    Transform.scale(
                      scale: scale,
                      alignment: Alignment.topCenter,
                      child: Image.file(File(_tempFile.path)),
                    ),

                  // Camera Action buttons
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: CameraActionButtons(
                        cameraType: widget.mode,
                        cameraCaptureState: _cameraCaptureState,
                        switchCameraLensDirection: switchCameraLensDirection,
                        canFlipCameraLensDirection:
                            areMultipleCamerasAvailable(),
                        takePicture: takePicture,
                        savePicture: () {
                          savePicture(noteSelected);
                        }),
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
                    const CircularProgressIndicator(
                      semanticsLabel: "Initialising camera",
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Opening camera",
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
