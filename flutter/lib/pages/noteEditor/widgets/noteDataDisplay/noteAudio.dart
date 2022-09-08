import 'package:flutter/material.dart';
import 'package:note_that/pages/noteEditor/widgets/audio/recorder/recorder.dart';
import 'package:note_that/stores/selectedNoteStore.dart';
import 'package:note_that/widgets/audioPlayer.dart';

class NoteAudio extends StatefulWidget {
  final AudioData audioData;
  final Function() onDelete;
  final Function() onShare;

  const NoteAudio(
      {Key? key,
      required this.audioData,
      required this.onDelete,
      required this.onShare})
      : super(key: key);

  @override
  State<NoteAudio> createState() => _NoteAudioState();
}

class _NoteAudioState extends State<NoteAudio> {
  late bool recorded;

  @override
  void initState() {
    super.initState();
    recorded = widget.audioData.getAudioFile().path != "";
  }

  void saveAudio(String? outputPath) {
    widget.audioData.setAudioFileWithPath(newAudioPath: outputPath as String);

    setState(() {
      recorded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return recorded

        // If already recorded, show audio player
        ? Column(
            children: [
              AudioPlayer(audioData: widget.audioData),
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
                    icon: const Icon(Icons.cancel_outlined,
                        color: Colors.redAccent),
                    iconSize: 24,
                  )
                ],
              ),
            ],
          )

        // If not recorded yet, show recorder
        : Recorder(saveAudio: saveAudio);
  }
}
