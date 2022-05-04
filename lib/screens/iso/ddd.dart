import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:helpers/helpers/misc.dart';
import 'package:helpers/helpers/transition.dart';
import 'package:provider/provider.dart';
import 'package:video_recorder_app/controller/clip_controller.dart';
import 'package:video_recorder_app/helpers/editor/domain/bloc/controller.dart';
import 'package:video_recorder_app/helpers/editor/ui/crop/crop_grid.dart';
import 'package:video_recorder_app/helpers/editor/ui/trim/trim_slider.dart';
import 'package:video_recorder_app/helpers/editor/ui/trim/trim_timeline.dart';

class DemoEditor extends StatefulWidget {
  const DemoEditor({Key? key, required this.path}) : super(key: key);
  final String path;

  @override
  State<DemoEditor> createState() => _DemoEditorState();
}

class _DemoEditorState extends State<DemoEditor> {
  // final _exportingProgress = ValueNotifier<double>(0.0);
  // final _isExporting = ValueNotifier<bool>(false);
  final double height = 60;

  bool _exported = false;
  String _exportText = "";
  late VideoEditorController _controller;
  @override
  void initState() {
    _controller = VideoEditorController.file(File(widget.path),
        maxDuration: Duration(hours: 1));
    _controller.initialize();
    // ..initialize().then((_) => setState(() {}));
    super.initState();
  }

  @override
  void dispose() {
    // _exportingProgress.dispose();
    // _isExporting.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _exportVideo() async {
    // _isExporting.value = true;

    await _controller.exportVideo(
      onCompleted: (file) async {
        // _isExporting.value = false;
        if (!mounted) return;
        if (file != null) {
          // await GallerySaver.saveVideo(file.path);
          // Provider.of<ClipController>(context, listen: false)
          //     .addMergeClip(file.path);
          Provider.of<ClipController>(context, listen: false)
              .addTrimmedSession(file.path);
          _exportText = "Video success export!";
        } else {
          _exportText = "Error on export video :(";
        }
        Navigator.pop(context);

        _exported = false;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.black,
      navigationBar: CupertinoNavigationBar(
        padding: EdgeInsetsDirectional.only(start: 5, end: 16),
        middle: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            CupertinoButton(
              padding: EdgeInsets.symmetric(vertical: 5),
              onPressed: () =>
                  _controller.rotate90Degrees(RotateDirection.left),
              child: Icon(Icons.rotate_left),
            ),
            CupertinoButton(
              padding: EdgeInsets.symmetric(vertical: 5),
              onPressed: () =>
                  _controller.rotate90Degrees(RotateDirection.right),
              child: Icon(Icons.rotate_right),
            ),
          ],
        ),
        trailing: CupertinoButton(
            padding: EdgeInsets.only(left: 20),
            child: Text('Save'),
            onPressed: () {
              _exportVideo();
            }),
        leading: CupertinoNavigationBarBackButton(
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      child: SafeArea(
        child: ListView(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                CropGridViewer(
                  controller: _controller,
                  showGrid: false,
                ),
                AnimatedBuilder(
                  animation: _controller.video,
                  builder: (_, __) => OpacityTransition(
                    visible: !_controller.isPlaying,
                    child: GestureDetector(
                      onTap: _controller.video.play,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.play_arrow, color: Colors.black),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            ..._trimSlider(),
            _customSnackBar()
          ],
        ),
      ),
    );
  }

  Widget _customSnackBar() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: SwipeTransition(
        visible: _exported,
        axisAlignment: 1.0,
        child: Container(
          height: height,
          width: double.infinity,
          color: Colors.black.withOpacity(0.8),
          child: Center(
            child: Text(_exportText,
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  // String formatter(Duration duration) => [
  //       duration.inMinutes.remainder(60).toString().padLeft(2, '0'),
  //       duration.inSeconds.remainder(60).toString().padLeft(2, '0')
  //     ].join(":");

  List<Widget> _trimSlider() {
    return [
      AnimatedBuilder(
        animation: _controller.video,
        builder: (_, __) {
          // final duration = _controller.video.value.duration.inSeconds;
          // final pos = _controller.trimPosition * duration;
          // final start = _controller.minTrim * duration;
          // final end = _controller.maxTrim * duration;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // SizedBox(width: 10),
              ],
            ),
          );
        },
      ),
      TrimSlider(
          child: TrimTimeline(
            controller: _controller,
            // margin: EdgeInsets.only(top: 10),
          ),
          controller: _controller,
          quality: 100,
          height: 50,
          horizontalMargin: height / 4),
    ];
  }
}
