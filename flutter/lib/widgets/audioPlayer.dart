import 'package:flutter/material.dart';
import 'package:note_that/stores/selectedNoteStore.dart';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:note_that/utils/time_counter.dart';
import 'package:note_that/widgets/snackbars.dart';
import 'package:provider/provider.dart';

enum AudioPlayerState { unprepared, readyToPlay, playing, paused, finished }

class AudioPlayer extends StatefulWidget {
  final AudioData? audioData;
  final bool miniPlayer;

  const AudioPlayer(
      {Key? key, required this.audioData, this.miniPlayer = false})
      : super(key: key);

  @override
  State<AudioPlayer> createState() => _AudioPlayerState();
}

class _AudioPlayerState extends State<AudioPlayer> {
  late PlayerController _playerController;
  AudioPlayerState _audioPlayerState = AudioPlayerState.unprepared;
  int _trackDurationMillis = 0;
  bool _error = false;

  @override
  void dispose() {
    _playerController.dispose();
    super.dispose();
  }

  // Function to prepare player
  Future<void> _preparePlayer(TimeCounter timeCounter) async {
    if ((_audioPlayerState == AudioPlayerState.unprepared ||
            _audioPlayerState == AudioPlayerState.finished) &&
        !_error) {
      try {
        _playerController = PlayerController();

        await _playerController
            .preparePlayer(widget.audioData?.getAudioFile().path ?? "");

        _playerController.onPlayerStateChanged.listen((newPlayerState) {
          // Whenever player is stopped, need to prepare the player again
          if (newPlayerState == PlayerState.stopped) {
            timeCounter.stop();
            setState(() {
              _audioPlayerState = AudioPlayerState.finished;
            });
          }
        });

        int newTrackDuration = await _playerController.getDuration();

        setState(() {
          _trackDurationMillis = newTrackDuration;
          _audioPlayerState = AudioPlayerState.readyToPlay;
        });
      } catch (e) {
        setState(() {
          _error = true;
        });
        SnackBars.showErrorMessage(context, "Could not load audio.");
      }
    }
  }

  // Function to toggle pause/resume
  Future<void> _togglePauseResume(TimeCounter timeCounter) async {
    try {
      if (_audioPlayerState == AudioPlayerState.paused) {
        // If paused, resume
        await _playerController.startPlayer();
        timeCounter.resume();
        setState(() {
          _audioPlayerState = AudioPlayerState.playing;
        });
      } else if (_audioPlayerState == AudioPlayerState.playing) {
        // If recording, pause
        await _playerController.pausePlayer();
        timeCounter.pause();
        setState(() {
          _audioPlayerState = AudioPlayerState.paused;
        });
      }
    } catch (e) {
      SnackBars.showErrorMessage(context, "Operation failed");
    }
  }

  // Function to toggle start/stop
  Future<void> _toggleStartStop(TimeCounter timeCounter) async {
    try {
      if (_audioPlayerState == AudioPlayerState.readyToPlay) {
        // If player is stopped, play.
        try {
          await _playerController.startPlayer();
          timeCounter.start();
          setState(() {
            _audioPlayerState = AudioPlayerState.playing;
          });
        } catch (e) {
          if (!mounted) return;
          SnackBars.showErrorMessage(context, e.toString());
        }
      } else if (_audioPlayerState == AudioPlayerState.playing ||
          _audioPlayerState == AudioPlayerState.paused) {
        // If playing, stop
        await _playerController.stopPlayer();
        timeCounter.stop();
      }
    } catch (e) {
      SnackBars.showErrorMessage(context, "Operation failed");
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<TimeCounter>(
      create: (_) => TimeCounter(updateInterval: const Duration(seconds: 1)),
      builder: (context, _) {
        TimeCounter timeCounter = Provider.of<TimeCounter>(context);
        _preparePlayer(timeCounter);

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Wave
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) =>
                      _audioPlayerState == AudioPlayerState.unprepared
                          ? (!_error
                              ?
                              // Spinner shown when audio player is preparing
                              const Center(
                                  child: SizedBox.square(
                                  dimension: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    semanticsLabel: "Loading audio...",
                                  ),
                                ))
                              :
                              // Error shown when preparing failed
                              Wrap(
                                  runAlignment: WrapAlignment.center,
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                      Text("Error",
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall),
                                      const Icon(
                                        Icons.error_outline,
                                        color: Colors.red,
                                        size: 20,
                                      )
                                    ]))
                          :

                          // Audio waveforms shown when player is prepared
                          GestureDetector(
                              onTap: () {
                                _toggleStartStop(timeCounter);
                              },
                              child: AudioFileWaveforms(
                                size: Size(constraints.maxWidth - 12, 80.0),
                                playerController: _playerController,
                                playerWaveStyle: PlayerWaveStyle(
                                  fixedWaveColor: Theme.of(context)
                                      .colorScheme
                                      .primary
                                      .withOpacity(0.5),
                                  liveWaveColor:
                                      Theme.of(context).colorScheme.primary,
                                ),
                              )),
                ),
              ),

              // Display timer and controls only if not a miniplayer
              if (!widget.miniPlayer) ...[
                // Timer
                Text(
                  "${timeCounter.formattedTime}/${TimeCounter.formatTime(_trackDurationMillis)}",
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(width: 4),

                // Pause/resume button (shown only when playing has started)
                IconButton(
                  icon: Icon(
                      _audioPlayerState == AudioPlayerState.paused
                          ? Icons.play_arrow
                          : Icons.pause,
                      color: Colors.black),
                  onPressed: _audioPlayerState != AudioPlayerState.readyToPlay
                      ? () {
                          _togglePauseResume(timeCounter);
                        }
                      : null,
                ),

                // Start/stop button (shown always)
                IconButton(
                  icon: Icon(
                      // This function figures out the icon to display
                      () {
                    if (_audioPlayerState == AudioPlayerState.unprepared) {
                      return Icons.play_disabled;
                    } else if (_audioPlayerState ==
                        AudioPlayerState.readyToPlay) {
                      return Icons.play_arrow;
                    } else if (_audioPlayerState == AudioPlayerState.playing ||
                        _audioPlayerState == AudioPlayerState.paused) {
                      return Icons.stop;
                    }
                  }(), color: Colors.red),
                  onPressed: () {
                    _toggleStartStop(timeCounter);
                  },
                ),
              ]
            ],
          ),
        );
      },
    );
  }
}
