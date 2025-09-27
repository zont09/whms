import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'dart:html' as html;

import 'package:whms/configs/color_config.dart';
import 'package:whms/untils/scale_utils.dart';
import 'package:whms/widgets/z_space.dart';

class AudioDialog extends StatefulWidget {
  final PlatformFile file;

  const AudioDialog({super.key, required this.file});

  @override
  _AudioDialogState createState() => _AudioDialogState();
}

class _AudioDialogState extends State<AudioDialog> {
  late html.AudioElement _audioElement;
  late String _audioUrl;
  bool _isPlaying = false;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _audioUrl = _createBlobUrl(widget.file);
    _audioElement = html.AudioElement();
    _audioElement.src = _createBlobUrl(widget.file);
    _audioElement.onTimeUpdate.listen(_onTimeUpdate);
    _audioElement.onEnded.listen(_onAudioEnded);
  }

  String _createBlobUrl(PlatformFile file) {
    final bytes = file.bytes;
    final blob = html.Blob([Uint8List.fromList(bytes!)]);
    return html.Url.createObjectUrlFromBlob(blob);
  }

  void _onTimeUpdate(html.Event e) {
    setState(() {
      _progress = (_audioElement.currentTime / _audioElement.duration) * 100;
    });
  }

  void _onAudioEnded(html.Event e) {
    setState(() {
      _isPlaying = false;
      _progress = 0.0;
    });
  }

  void _togglePlayPause() {
    if (_isPlaying) {
      _audioElement.pause();
    } else {
      _audioElement.play();
    }
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  void _seekTo(double value) {
    final duration = _audioElement.duration;
    final seekTime = duration * (value / 100);
    _audioElement.currentTime = seekTime;
  }

  @override
  void dispose() {
    html.Url.revokeObjectUrl(_audioUrl);
    if (_isPlaying) {
      _audioElement.pause();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: ScaleUtils.scaleSize(340, context),
      padding: EdgeInsets.all(ScaleUtils.scaleSize(8, context)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.file.name * 4,
            style: TextStyle(
                fontSize: ScaleUtils.scaleSize(24, context),
                fontWeight: FontWeight.w700,
                color: ColorConfig.textColor,
                overflow: TextOverflow.ellipsis),
          ),
          const ZSpace(h: 12),
          Row(
            children: [
              IconButton(
                color: ColorConfig.primary3,
                icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                onPressed: _togglePlayPause,
              ),
              Expanded(
                child: Slider(
                  activeColor: ColorConfig.primary3,
                  value: _progress,
                  min: 0,
                  max: 100,
                  onChanged: _seekTo,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}