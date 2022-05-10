import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:provider/provider.dart';
import 'package:video_recorder_app/controller/clip_controller.dart';
import 'package:video_recorder_app/helpers/trimmer/src/trim_editor.dart';
import 'package:video_recorder_app/helpers/trimmer/src/trimmer.dart';
import 'package:video_recorder_app/screens/editor/videoeditorpage.dart';
import 'package:video_recorder_app/screens/homepage.dart';

class IOSEditClipPage extends StatelessWidget {
  const IOSEditClipPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var clipCon = Provider.of<ClipController>(context);
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.darkBackgroundGray,
      navigationBar: CupertinoNavigationBar(
        padding: EdgeInsetsDirectional.zero,
        leading: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(width: 2),
            GestureDetector(
              onTap: () {
                _showMyDialog(context);
              },
              child: Icon(
                CupertinoIcons.back,
              ),
            ),
            SizedBox(width: 5),
            Text(
              'Edit Clips',
              style: TextStyle(
                  color: CupertinoColors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.bold),
            )
          ],
        ),
        trailing: clipCon.timmedSessionList.isNotEmpty
            ? CupertinoButton(
                padding: EdgeInsets.only(right: 15),
                child: Text('Merge'),
                onPressed: () {
                  clipCon.mergeRequest();
                },
              )
            : null,
      ),
      child: ListView.builder(
        itemCount: clipCon.clippedSessionList.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomSliders(
                customSlidersPath: clipCon.clippedSessionList[index]),
          );
        },
      ),
    );
  }

  Future<void> _showMyDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Clear Sessions'),
          content: Text('Do you want to clear all recorded Sessions'),
          actions: <Widget>[
            CupertinoDialogAction(
                child: const Text('No'),
                onPressed: () {
                  Navigator.pop(context);
                }),
            CupertinoDialogAction(
              child: const Text('Yes'),
              onPressed: () async {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RecordingPage(),
                    ),
                    (route) => false);

                Provider.of<ClipController>(context, listen: false)
                    .onFinished();
              },
            ),
          ],
        );
      },
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
  Timer? _timer;

  @override
  void initState() {
    _loadVideo();
    super.initState();
    EasyLoading.addStatusCallback((status) {
      print('EasyLoading Status $status');
      if (status == EasyLoadingStatus.dismiss) {
        _timer?.cancel();
      }
    });
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
          CupertinoPageRoute(
            builder: (context) => VideoEditor(
              file: File(widget.customSlidersPath),
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
