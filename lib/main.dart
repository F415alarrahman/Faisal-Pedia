import 'package:faisal_pedia/module/splash_screen_page.dart';
import 'package:faisal_pedia/utils/custom_scroll.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scrollBehavior: MyCustomScrollBehavior(),
      home: SplashScreenPage(),
      debugShowCheckedModeBanner: false,
      title: "Faisal Pedia",
    );
  }
}
