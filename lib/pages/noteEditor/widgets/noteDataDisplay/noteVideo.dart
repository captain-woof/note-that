import 'package:flutter/material.dart';
import 'package:note_that/stores/selectedNoteStore.dart';
import 'package:note_that/widgets/videoPlayer.dart';
import 'package:flutter_video_info/flutter_video_info.dart' as video_info;

class NoteVideo extends StatelessWidget {
  final VideoData videoData;
  final Function() onDelete;
  final Function() onShare;

  const NoteVideo(
      {Key? key,
      required this.videoData,
      required this.onDelete,
      required this.onShare})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Video player and controls
        _NoteVideoPlayer(videoData: videoData),

        // Action buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Share button
            IconButton(
              onPressed: onShare,
              icon: Icon(Icons.share,
                  color: Theme.of(context).colorScheme.primary),
              iconSize: 24,
            ),

            // Delete button
            IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.cancel_outlined, color: Colors.redAccent),
              iconSize: 24,
            )
          ],
        ),
      ],
    );
  }
}

class _NoteVideoPlayer extends StatelessWidget {
  final VideoData videoData;

  const _NoteVideoPlayer({Key? key, required this.videoData}) : super(key: key);

  Future<video_info.VideoData?> _getVideoMediaInfoFuture() =>
      video_info.FlutterVideoInfo().getVideoInfo(videoData.getVideoFile().path);

  double getVideoContainerHeight(
          BuildContext context, video_info.VideoData videoInfo) =>
      (MediaQuery.of(context).size.width /
          ((videoInfo.width ?? 0) / (videoInfo.height ?? 1)));

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _getVideoMediaInfoFuture(),
      initialData: const <String, dynamic>{},
      builder: (context, snapshot) {
        // If media info is read, show video player
        if (snapshot.connectionState == ConnectionState.done) {
          var mediaInfo = snapshot.data as video_info.VideoData;
          return SizedBox(
            width: double.infinity,
            height: getVideoContainerHeight(context, mediaInfo),
            child: VideoPlayer(
              videoData: videoData,
              loop: true,
              videoPlayerMode: VideoPlayerMode.withControls,
            ),
          );
        }

        // If media info is being read, show spinner
        else {
          return SizedBox(
            width: double.infinity,
            height: 100,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      semanticsLabel: "Loading video...",
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Loading video...",
                    style: Theme.of(context).textTheme.bodySmall,
                  )
                ],
              ),
            ),
          );
        }
      },
    );
  }
}
