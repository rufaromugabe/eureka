import 'package:flutter/material.dart';

class Assessment extends StatefulWidget {
  const Assessment({super.key});

  @override
  State<Assessment> createState() => _AssessmentState();
}

class _AssessmentState extends State<Assessment> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Assessment'),
      ),
      body: Center(child: Text('Assessment')),
    );
  }
}
