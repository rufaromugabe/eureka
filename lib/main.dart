import 'package:eureka/ask.dart';
import 'package:eureka/assessmentscreen.dart';
import 'package:eureka/examscreen.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

CameraDescription? firstCamera;
Future<void> main() async {
  runApp(MyApp());
}

final String apiKey = "AIzaSyDRiI5PgPjGCoWOjOZxSf0a5P_6lirLPQc";

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _currentIndex = 0;
  final List<Widget> _children = [AskAi(), ExamScreen(), AssessmentScreen()];

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
          items: [
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
