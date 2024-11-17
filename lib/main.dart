// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:travelvn/screens/splash.dart';
import 'package:http/http.dart' as http;
import 'package:travelvn/themes/app_theme.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'http package',
      theme: AppTheme.ligtTheme,
      home: const Splash(),
    );
  }
}
