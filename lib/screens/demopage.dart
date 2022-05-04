import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_recorder_app/controller/clip_controller.dart';
import 'package:video_recorder_app/helpers/trimmer/src/trim_editor.dart';
import 'package:video_recorder_app/helpers/trimmer/src/trimmer.dart';
import 'package:video_recorder_app/screens/single_trimm_page.dart';

class DemoPage extends StatefulWidget {
  const DemoPage({Key? key}) : super(key: key);

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  @override
  Widget build(BuildContext context) {
    var clipCon = Provider.of<ClipController>(context);
    return Scaffold(
      appBar: AppBar(
        actions: [
          ElevatedButton(
            onPressed: () async {
              await clipCon.mergeRequest();
            },
            child: Text('Merge'),
          ),
          ElevatedButton(
            onPressed: () {
              // clipCon.mergeRequest();
              print('Trimmed List: ${clipCon.timmedSessionList}');
              clipCon.timmedSessionList;
            },
            child: Text('Trimmed List'),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: clipCon.clippedSessionList.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomSliders(
                customSlidersPath: clipCon.clippedSessionList[index]),
          );
          // return Padding(
          //   padding: const EdgeInsets.all(8.0),
          // child: ListTile(
          //   onTap: () {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => SingleTrimPage(
          //       path: clipCon.clippedSessionList[index],
          //     ),
          //   ),
          // );
          //   },
          //   tileColor: Colors.red,
          //   title: Text(
          //     clipCon.clippedSessionList[index],
          //   ),
          // ),
          //);
        },
      ),
    );
  }
}

class CustomSliders extends StatefulWidget {
  const CustomSliders({Key? key, required this.customSlidersPath})
      : super(key: key);
  final String customSlidersPath;

  @override
  State<CustomSliders> createState() => _CustomSlidersState();
}

class _CustomSlidersState extends State<CustomSliders> {
  final Trimmer _trimmer = Trimmer();

  @override
  void initState() {
    _loadVideo();
    super.initState();
  }

  Future<void> _loadVideo() async {
    await _trimmer.loadVideo(videoFile: File(widget.customSlidersPath));
  }

  void dispose() {
    _trimmer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SingleTrimPage(
              path: widget.customSlidersPath,
            ),
          ),
        );
      },
      child: TrimEditor(
        trimmer: _trimmer,
        circlePaintColor: Colors.transparent,
        borderPaintColor: Colors.transparent,
        viewerHeight: 50.0,
        showDuration: false,
        thumbnailQuality: 25,
        viewerWidth: MediaQuery.of(context).size.width,
        maxVideoLength: const Duration(hours: 10),
        onChangeStart: (value) {},
        onChangeEnd: (value) {},
        onChangePlaybackState: (value) {},
      ),
    );
  }
}
