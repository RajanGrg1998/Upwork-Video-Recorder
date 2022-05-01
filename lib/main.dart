import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_better_camera/camera.dart';
import 'package:provider/provider.dart';
import 'package:video_recorder_app/controller/clip_controller.dart';
import 'package:video_recorder_app/screens/homepage.dart';

List<CameraDescription> cameras = [];
Future<void> main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();

    cameras = await availableCameras();
  } on CameraException catch (e) {
    print('Error in fetching the cameras: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => ClipController(),
        )
      ],
      child: const CupertinoApp(
        debugShowCheckedModeBanner: false,
        localizationsDelegates: <LocalizationsDelegate<dynamic>>[
          DefaultMaterialLocalizations.delegate,
          DefaultWidgetsLocalizations.delegate,
          DefaultCupertinoLocalizations.delegate,
        ],
        theme: CupertinoThemeData(
            brightness: Brightness.light,
            textTheme: CupertinoTextThemeData(
              textStyle: TextStyle(fontFamily: 'SF-Pro'),
            )),
        title: 'Flutter Demo',
        home: RecordingPage(),
      ),
    );
  }
}
