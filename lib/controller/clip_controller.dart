import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit_config.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';

class ClipController extends ChangeNotifier {
  List<String> fullSessionList = [];
  List<String> clippedSessionList = [];
  List<String> timmedSessionList = [];

  addFullSession(String filepath) {
    fullSessionList.add(filepath);
    notifyListeners();
  }

//for clipped list session
  clipedLastSecond(String filepath) {
    clippedSessionList.add(filepath);
    notifyListeners();
  }

//for adding trimmed session list
  addTrimmedSession(String filepath) {
    timmedSessionList.add(filepath);
    notifyListeners();
  }

  Future<void> mergeRequest() async {
    final appDir = await getApplicationDocumentsDirectory();
    String rawDocumentPath = appDir.path;
    final outputPath = '$rawDocumentPath/output.mp4';

    List<String> mergedList = [];
    for (int i = 0; i < timmedSessionList.length; i++) {
      mergedList.add('-i ${timmedSessionList[i]}');
    }
    mergedList.add('-filter_complex');
    mergedList.add('"');
    for (int i = 0; i < timmedSessionList.length; i++) {
      mergedList.add('[$i:v] [$i:a]');
    }
    mergedList.add(
        'concat=n=${timmedSessionList.length}:v=1:a=1 [v] [a]" -map "[v]" -map "[a]"');
    String result = mergedList.join(' ');
    String commandToExecute = '$result -y $outputPath';
    print(commandToExecute);
    FFmpegKit.executeAsync(commandToExecute, (session) async {
      final state =
          FFmpegKitConfig.sessionStateToString(await session.getState());
      final returnCode = await session.getReturnCode();

      debugPrint("FFmpeg process exited with state $state and rc $returnCode");

      if (ReturnCode.isSuccess(returnCode)) {
        debugPrint("FFmpeg processing completed successfully.");
        debugPrint('Video successfuly saved');
        onSave(outputPath);
      } else {
        debugPrint("FFmpeg processing failed.");
        debugPrint('Couldn\'t save the video');
        // onSave(null);
      }
    });
  }

  void onSave(String filepath) async {
    await GallerySaver.saveVideo(filepath);
  }
}
