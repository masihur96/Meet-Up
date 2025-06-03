import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AudioMessagePreview extends StatefulWidget {
  final String audioUrl;
  final Color color;
  final String? fileName;

  const AudioMessagePreview({
    Key? key,
    required this.audioUrl,
    required this.color,
    this.fileName,
  }) : super(key: key);

  @override
  State<AudioMessagePreview> createState() => _AudioMessagePreviewState();
}

class _AudioMessagePreviewState extends State<AudioMessagePreview> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initAudioPlayer();
  }

  Future<void> _initAudioPlayer() async {
    try {
      await _audioPlayer.setUrl(widget.audioUrl);
      _duration = _audioPlayer.duration ?? Duration.zero;
      
      _audioPlayer.positionStream.listen((position) {
        if (mounted) {
          setState(() {
            _position = position;
          });
        }
      });

      _audioPlayer.playerStateStream.listen((state) {
        if (mounted) {
          setState(() {
            _isPlaying = state.playing;
          });
        }
      });
    } catch (e) {
      debugPrint('Error initializing audio: $e');
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
              onPressed: () {
                if (_isPlaying) {
                  _audioPlayer.pause();
                } else {
                  _audioPlayer.play();
                }
              },
            ),
            SizedBox(
              width: 200,
              child: Slider(
                value: _position.inSeconds.toDouble(),
                max: _duration.inSeconds.toDouble(),
                onChanged: (value) {
                  _audioPlayer.seek(Duration(seconds: value.toInt()));
                },
              ),
            ),

          ],
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
          Text(_formatDuration(_position)),
          const Text(' / '),
          Text(_formatDuration(_duration)),
        ],),

      ],
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
