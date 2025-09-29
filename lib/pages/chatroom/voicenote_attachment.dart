import 'dart:async';

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

class VoiceNoteAttachment extends StatefulWidget {
  final Attachment attachment;
  final String? audioUrl;

  const VoiceNoteAttachment({
    super.key,
    required this.attachment,
    this.audioUrl,
  });

  @override
  State<VoiceNoteAttachment> createState() => _VoiceNoteAttachmentState();
}

class _VoiceNoteAttachmentState extends State<VoiceNoteAttachment> {
  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  StreamSubscription? _durationSub;
  StreamSubscription? _positionSub;
  StreamSubscription? _payerStateSub;

  @override
  void initState() {
    super.initState();

    _payerStateSub = _player.onPlayerStateChanged.listen((state) {
      setState(() => _isPlaying = state == PlayerState.playing);
    });

    _durationSub = _player.onDurationChanged.listen((d) {
      setState(() => _duration = d);
    });

    _positionSub = _player.onPositionChanged.listen((p) {
      setState(() => _position = p);
    });
  }

  Future<void> _togglePlay() async {
    final url = widget.attachment.assetUrl ?? widget.attachment.file?.path;
    print("########### URL: $url #################");
    if (url == null) return;

    if (_isPlaying) {
      await _player.pause();
    } else {
      await _player.play(UrlSource(url));
    }
  }

  @override
  void dispose() {
    _durationSub?.cancel();
    _positionSub?.cancel();
    _payerStateSub?.cancel();
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.symmetric(vertical: 4),

      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(
                  _isPlaying ? Icons.pause_circle : Icons.play_circle,
                  size: 36,
                  color: Colors.blue,
                ),
                onPressed: _togglePlay,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Slider(
                      min: 0,
                      max: _duration.inSeconds.toDouble(),
                      value: _position.inSeconds
                          .clamp(0, _duration.inSeconds)
                          .toDouble(),
                      onChanged: (value) async {
                        final position = Duration(seconds: value.toInt());
                        await _player.seek(position);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          Text(
            "${_formatDuration(_position)} / ${_formatDuration(_duration)}",
            style: const TextStyle(fontSize: 12, color: Colors.black),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, "0");
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, "0");
    return "$minutes:$seconds";
  }
}
