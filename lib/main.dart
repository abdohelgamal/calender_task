import 'package:calender_task/home_calander.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          primaryColorLight: const Color(0xFF4CC0BD),
          primaryColor: const Color(0xFF4CC0BD),
          secondaryHeaderColor: const Color(0xFFFFA122),
          colorScheme: const ColorScheme(
              brightness: Brightness.light,
              primary: Color(0xFF4CC0BD),
              onPrimary: Colors.white,
              secondary: Color(0xFFFFA122),
              onSecondary: Colors.white,
              error: Colors.red,
              onError: Colors.white,
              background: Colors.white,
              onBackground: Colors.black,
              surface: Colors.grey,
              onSurface: Colors.black)),
      home: const MyHomePage(),
    );
  }
}
