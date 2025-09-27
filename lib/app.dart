import 'package:flutter/material.dart';
import 'package:sumeeb_chat/pages/splash-screen/splashscreen.dart';
import 'package:sumeeb_chat/services/stream_service.dart';
import 'package:sumeeb_chat/styles/color_schemes.dart';

class MyApp extends StatelessWidget {
  final StreamService streamService;
  const MyApp({super.key, required this.streamService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat App',
      theme: ThemeData(colorScheme: myColorScheme),
      home: SplashScreen(streamService: streamService),
    );
  }
}
