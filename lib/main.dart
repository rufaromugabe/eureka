import 'package:camera/camera.dart';
import 'package:eureka/ask.dart';
import 'package:eureka/assessmentscreen.dart';
import 'package:eureka/examscreen.dart';
import 'package:flutter/material.dart';

CameraDescription? firstCamera;
Future<void> main() async {
  runApp(const MyApp());
}

const String apiKey = "AIzaSyDRiI5PgPjGCoWOjOZxSf0a5P_6lirLPQc";

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  int _currentIndex = 0;
  final List<Widget> _children = [
    const AskAi(),
    const ExamScreen(),
    const AssessmentScreen()
  ];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      home: Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _children,
        ),
        bottomNavigationBar: BottomNavigationBar(
          onTap: onTabTapped,
          selectedItemColor: Colors.deepPurple,
          currentIndex: _currentIndex,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.question_answer_outlined),
              label: 'Ask Ai',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.book_rounded),
              label: 'Exams',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assessment),
              label: 'Assessment',
            ),
          ],
        ),
      ),
    );
  }
}
