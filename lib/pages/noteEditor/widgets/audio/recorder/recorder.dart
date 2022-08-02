import 'package:flutter/material.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:note_that/utils/time_counter.dart';
import 'package:note_that/widgets/snackbars.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';

enum RecorderState { beforeRecord, recording, paused, stopped }

class Recorder extends StatefulWidget {
  final Function(String?) saveAudio;

  const Recorder({Key? key, required this.saveAudio}) : super(key: key);

  @override
  State<Recorder> createState() => _RecorderState();
}

class _RecorderState extends State<Recorder> {
  late final RecorderController _recorderController;
  late RecorderState _recorderState;

  @override
  void initState() {
    super.initState();

    // Initialise recorder
    _recorderController = RecorderController();
    _recorderState = RecorderState.beforeRecord;
  }

  @override
  void dispose() {
    _recorderController.dispose();
    super.dispose();
  }

  // Function to toggle pause/resume
  Future<void> togglePauseResume(TimeCounter timeCounter) async {
    if (_recorderState == RecorderState.paused) {
      // If paused, resume
      await _recorderController.record();
      timeCounter.resume();
      setState(() {
        _recorderState = RecorderState.recording;
      });
    } else if (_recorderState == RecorderState.recording) {
      // If recording, pause
      await _recorderController.pause();
      timeCounter.pause();
      setState(() {
        _recorderState = RecorderState.paused;
      });
    }
  }

  // Function to toggle start/stop
  Future<void> toggleStartStop(TimeCounter timeCounter) async {
    if (_recorderState == RecorderState.beforeRecord) {
      // If recording not started yet, record
      try {
        String savePath = path.join(
            (await getApplicationDocumentsDirectory()).path,
            "${DateTime.now().millisecondsSinceEpoch.toString()}.aac");
        await _recorderController.record(savePath);
        timeCounter.start();
        setState(() {
          _recorderState = RecorderState.recording;
        });
      } catch (e) {
        SnackBars.showErrorMessage(context, "Failed to start recording.");
      }
    } else if (_recorderState == RecorderState.recording ||
        _recorderState == RecorderState.paused) {
      // If recording, stop
      String? filePath = await _recorderController.stop();
      if (filePath != null) {
        widget.saveAudio(filePath);
      }
      timeCounter.stop();
      setState(() {
        _recorderState = RecorderState.stopped;
      });
    }
  }

  @override
  Widget build(BuildContext _) {
    return ChangeNotifierProvider<TimeCounter>(
      create: (_) => TimeCounter(updateInterval: const Duration(seconds: 1)),
      builder: (context, _) {
        TimeCounter timeCounter = Provider.of<TimeCounter>(context);

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Wave
              Expanded(
                child: LayoutBuilder(
                  builder: (_, constraints) {
                    return AudioWaveforms(
                        size: Size(constraints.maxWidth, 80),
                        recorderController: _recorderController,
                        waveStyle: WaveStyle(
                            showDurationLabel: false,
                            extendWaveform: true,
                            durationLinesHeight: 0,
                            showMiddleLine: false,
                            spacing: 12,
                            waveColor: Theme.of(context).colorScheme.primary,
                            waveThickness: 4));
                  },
                ),
              ),

              // Timer
              const SizedBox(width: 4),
              Text(
                timeCounter.formattedTime,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(width: 4),

              // Pause/resume button (shown only when recording has started)
              IconButton(
                icon: Icon(
                    _recorderState == RecorderState.paused
                        ? Icons.play_arrow
                        : Icons.pause,
                    color: Colors.black),
                onPressed: _recorderState != RecorderState.beforeRecord
                    ? () {
                        togglePauseResume(timeCounter);
                      }
                    : null,
              ),

              // Start/stop button (shown always)
              IconButton(
                icon: Icon(
                    _recorderState == RecorderState.beforeRecord
                        ? Icons.circle
                        : Icons.stop,
                    color: Colors.red),
                onPressed: () {
                  toggleStartStop(timeCounter);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
