import 'dart:io';
import 'package:flutter/material.dart';
import 'package:note_that/stores/selectedNoteStore.dart';
import 'package:video_player/video_player.dart' as video_player;

enum VideoPlayerMode { withoutControls, withControls }

// ignore: must_be_immutable
class VideoPlayer extends StatefulWidget {
  VideoData? videoData;
  VideoPlayerMode videoPlayerMode;
  bool autoPlay;
  bool loop;

  VideoPlayer(
      {Key? key,
      required this.videoData,
      this.videoPlayerMode = VideoPlayerMode.withoutControls,
      this.autoPlay = false,
      this.loop = false})
      : super(key: key);

  VideoPlayer.fromPath(
      {Key? key,
      required String videoPath,
      this.videoPlayerMode = VideoPlayerMode.withoutControls,
      this.autoPlay = false,
      this.loop = false})
      : super(key: key) {
    videoData = VideoData.fromPath(videoPath: videoPath);
  }

  VideoPlayer.fromFile(
      {Key? key,
      required File videoFile,
      this.videoPlayerMode = VideoPlayerMode.withoutControls,
      this.autoPlay = false,
      this.loop = false})
      : super(key: key) {
    videoData = VideoData(videoFile: videoFile);
  }

  @override
  State<VideoPlayer> createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer> {
  late video_player.VideoPlayerController _videoPlayerController;
  bool autoPlayed = false;

  @override
  void initState() {
    super.initState();

    // Initialize video player
    _videoPlayerController = video_player.VideoPlayerController.file(
        widget.videoData?.getVideoFile() as File);
    _videoPlayerController.initialize().then((_) {
      // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
      _videoPlayerController.setLooping(widget.loop);
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    _videoPlayerController.dispose();
  }

  Future<void> playVideo({Function()? callback}) {
    return _videoPlayerController.play().then((_) {
      setState(callback ?? () {});
    });
  }

  Future<void> pauseVideo({Function()? callback}) {
    return _videoPlayerController.pause().then((_) {
      setState(callback ?? () {});
    });
  }

  @override
  Widget build(BuildContext context) {
    // Auto-play only if configured AND if this is the first time playing
    if (widget.autoPlay && !autoPlayed) {
      Future.delayed(const Duration(milliseconds: 500), () async {
        await playVideo(callback: () {
          autoPlayed = true;
        });
      });
    }

    return GestureDetector(
      onTap: () async {
        if (_videoPlayerController.value.isPlaying) {
          await pauseVideo();
        } else {
          await playVideo();
        }
      },
      // Video player + Controls
      child: Stack(
        children: [
          // Video player
          video_player.VideoPlayer(_videoPlayerController),

          // Action buttons (if needed)
          if (widget.videoPlayerMode == VideoPlayerMode.withControls)
            Align(
                alignment: Alignment.bottomCenter,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Play/pause button
                    VideoPlayerActionIconButton(
                        icon: _videoPlayerController.value.isPlaying
                            ? Icons.pause
                            : Icons.play_arrow,
                        onPressed: () async {
                          if (_videoPlayerController.value.isPlaying) {
                            await pauseVideo();
                          } else {
                            await playVideo();
                          }
                          setState(() {});
                        },
                        semanticLabel:
                            "${_videoPlayerController.value.isPlaying ? 'Pause' : 'Resume'} video playback")
                  ],
                ))
        ],
      ),
    );
  }
}

class VideoPlayerActionIconButton extends StatelessWidget {
  final IconData icon;
  final Function()? onPressed;
  final String semanticLabel;
  final double size;
  final Color? color;

  const VideoPlayerActionIconButton(
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
