import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'full_screen_video_player.dart';

class VideoPreview extends StatefulWidget {
  final String videoUrl;
  final String? fileName;

  const VideoPreview({super.key, required this.videoUrl, this.fileName});

  @override
  State<VideoPreview> createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<VideoPreview> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        setState(() => _isInitialized = true);
        _controller.pause();
      });

  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openFullScreenPlayer() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullScreenVideoPlayer(videoUrl: widget.videoUrl),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _isInitialized
        ? GestureDetector(
      onTap: _openFullScreenPlayer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),
              const Icon(Icons.play_circle_fill, size: 64, color: Colors.white),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.fileName ?? "Video",
            style: const TextStyle(
              color: Colors.white,
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
    )
        : const CircularProgressIndicator();
  }
}
