import 'package:flutter/material.dart';
import 'package:note_that/pages/noteEditor/widgets/audio/recorder/recorder.dart';
import 'package:note_that/stores/selectedNoteStore.dart';
import 'package:note_that/widgets/audioPlayer.dart';

class NoteAudio extends StatefulWidget {
  final AudioData audioData;
  final Function() onDelete;

  const NoteAudio({Key? key, required this.audioData, required this.onDelete})
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
              IconButton(
                onPressed: widget.onDelete,
                icon:
                    const Icon(Icons.cancel_outlined, color: Colors.redAccent),
                iconSize: 20,
              )
            ],
          )

        // If not recorded yet, show recorder
        : Recorder(saveAudio: saveAudio);
  }
}
