import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'full_screen_video_player.dart';

class VideoPreview extends StatefulWidget {
  final String videoUrl;
  final String? fileName;

  const VideoPreview({Key? key, required this.videoUrl, this.fileName}) : super(key: key);

  @override
  State<VideoPreview> createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<VideoPreview> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    _controller = VideoPlayerController.network(widget.videoUrl);
    try {
      await _controller.initialize();
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      debugPrint('Error initializing video: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_isInitialized)
          AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          )
        else
          const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          ),
        if (widget.fileName != null)
          Padding(
            padding: const EdgeInsets.only(top: 4.0),
            child: Text(widget.fileName!),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
