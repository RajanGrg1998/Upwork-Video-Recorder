import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:helpers/helpers/transition.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:video_recorder_app/controller/clip_controller.dart';

import '../../helpers/editor/video_editor.dart';

class VideoEditor extends StatefulWidget {
  const VideoEditor({Key? key, required this.file}) : super(key: key);

  final File file;

  @override
  _VideoEditorState createState() => _VideoEditorState();
}

class _VideoEditorState extends State<VideoEditor> {
  // final _exportingProgress = ValueNotifier<double>(0.0);
  // final _isExporting = ValueNotifier<bool>(false);
  final double height = 60;

  bool _exported = false;
  String _exportText = "";
  late VideoEditorController _controller;

  @override
  void initState() {
    _controller = VideoEditorController.file(widget.file,
        maxDuration: const Duration(seconds: 30))
      ..initialize().then((_) => setState(() {}));
    super.initState();
  }

  @override
  void dispose() {
    // _exportingProgress.dispose();
    // _isExporting.dispose();
    _controller.dispose();
    super.dispose();
  }

  // void _openCropScreen() => Navigator.push(
  //     context,
  //     MaterialPageRoute<void>(
  //         builder: (BuildContext context) =>
  //             CropScreen(controller: _controller)));

  // void _exportVideo() async {
  //   _exportingProgress.value = 0;
  //   _isExporting.value = true;
  //   // NOTE: To use `-crf 1` and [VideoExportPreset] you need `ffmpeg_kit_flutter_min_gpl` package (with `ffmpeg_kit` only it won't work)
  //   await _controller.exportVideo(
  //     // preset: VideoExportPreset.medium,
  //     // customInstruction: "-crf 17",
  //     // onProgress: (stats, value) => _exportingProgress.value = value,
  //     onCompleted: (file) {
  //       _isExporting.value = false;
  //       if (!mounted) return;
  //       if (file != null) {
  //         Provider.of<ClipController>(context, listen: false)
  //             .addTrimmedSession(file.path);
  //         _exportText = "Video success export!";
  //       } else {
  //         _exportText = "Error on export video :(";
  //       }

  //       setState(() => _exported = true);
  //       _exported = false;
  //       Navigator.pop(context);
  //     },
  //   );
  // }\

  void _exportVideo() async {
    // _isExporting.value = true;
    EasyLoading.show(status: 'Video Trimming...');
    await _controller.exportVideo(
      onCompleted: (file) async {
        // _isExporting.value = false;
        if (!mounted) return;
        if (file != null) {
          Provider.of<ClipController>(context, listen: false)
              .addTrimmedSession(file.path);
          EasyLoading.showSuccess('Video Trimmed!');
          _exportText = "Video success export!";
          EasyLoading.dismiss();
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
    return Scaffold(
      backgroundColor: Colors.black,
      body: _controller.initialized
          ? SafeArea(
              child: Stack(
                children: [
                  Column(
                    children: [
                      _topNavBar(),
                      Expanded(
                        child: DefaultTabController(
                          length: 2,
                          child: Column(
                            children: [
                              Expanded(
                                  child: TabBarView(
                                physics: const NeverScrollableScrollPhysics(),
                                children: [
                                  Stack(alignment: Alignment.center, children: [
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
                                            decoration: const BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(Icons.play_arrow,
                                                color: Colors.black),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ]),
                                  CoverViewer(controller: _controller)
                                ],
                              )),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: _trimSlider(),
                              ),
                              _customSnackBar(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _topNavBar() {
    return SafeArea(
      child: SizedBox(
        height: height,
        child: Row(
          children: [
            Expanded(
              child: IconButton(
                onPressed: () =>
                    _controller.rotate90Degrees(RotateDirection.left),
                icon: const Icon(Icons.rotate_left),
              ),
            ),
            Expanded(
              child: IconButton(
                onPressed: () =>
                    _controller.rotate90Degrees(RotateDirection.right),
                icon: const Icon(Icons.rotate_right),
              ),
            ),
            // Expanded(
            //   child: IconButton(
            //     onPressed: _openCropScreen,
            //     icon: const Icon(Icons.crop),
            //   ),
            // ),
            // Expanded(
            //   child: IconButton(
            //     onPressed: _exportCover,
            //     icon: const Icon(Icons.save_alt, color: Colors.white),
            //   ),
            // ),
            Expanded(
              child: IconButton(
                onPressed: _exportVideo,
                icon: const Icon(Icons.save),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String formatter(Duration duration) => [
        duration.inMinutes.remainder(60).toString().padLeft(2, '0'),
        duration.inSeconds.remainder(60).toString().padLeft(2, '0')
      ].join(":");

  List<Widget> _trimSlider() {
    return [
      AnimatedBuilder(
        animation: _controller.video,
        builder: (_, __) {
          final duration = _controller.video.value.duration.inSeconds;
          final pos = _controller.trimPosition * duration;
          final start = _controller.minTrim * duration;
          final end = _controller.maxTrim * duration;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: height / 4),
            child: Row(children: [
              Text(formatter(Duration(seconds: pos.toInt()))),
              const Expanded(child: SizedBox()),
              OpacityTransition(
                visible: _controller.isTrimming,
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(
                    formatter(
                      Duration(
                        seconds: start.toInt(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    formatter(
                      Duration(
                        seconds: end.toInt(),
                      ),
                    ),
                  ),
                ]),
              )
            ]),
          );
        },
      ),
      Container(
        width: MediaQuery.of(context).size.width,
        margin: EdgeInsets.symmetric(vertical: height / 4),
        child: TrimSlider(
            // child: TrimTimeline(
            //     controller: _controller,
            //     margin: const EdgeInsets.only(top: 10)),
            controller: _controller,
            height: height,
            horizontalMargin: height / 4),
      )
    ];
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
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}
