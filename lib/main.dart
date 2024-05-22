import 'package:eureka/examscreen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Exam Paper',
      theme: ThemeData.dark(useMaterial3: true),
      home: ExamScreen(),
    );
  }
}
