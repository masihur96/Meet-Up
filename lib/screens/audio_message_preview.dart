import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioMessagePreview extends StatefulWidget {
  final String audioUrl;
  final Color color;

  const AudioMessagePreview({required this.audioUrl, required this.color, Key? key}) : super(key: key);

  @override
  State<AudioMessagePreview> createState() => _AudioMessagePreviewState();
}

class _AudioMessagePreviewState extends State<AudioMessagePreview> {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _player.setSourceUrl(widget.audioUrl);
    _player.onDurationChanged.listen((d) => setState(() => _duration = d));
    _player.onPositionChanged.listen((p) => setState(() => _position = p));
    _player.onPlayerComplete.listen((_) => setState(() => _isPlaying = false));
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void _togglePlayPause() async {
    if (_isPlaying) {
      await _player.pause();
    } else {
      await _player.resume();
    }
    setState(() => _isPlaying = !_isPlaying);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: Icon(_isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill, color: widget.color),
          onPressed: _togglePlayPause,
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Slider(
                value: _position.inSeconds.toDouble(),
                max: _duration.inSeconds.toDouble().clamp(1.0, double.infinity),
                onChanged: (value) async {
                  await _player.seek(Duration(seconds: value.toInt()));
                },
                activeColor: widget.color,
                inactiveColor: widget.color.withOpacity(0.3),
              ),
              Text(
                '${_formatTime(_position)} / ${_formatTime(_duration)}',
                style: TextStyle(color: widget.color, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatTime(Duration d) {
    final minutes = d.inMinutes.toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
