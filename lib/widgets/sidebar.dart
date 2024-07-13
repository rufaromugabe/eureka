import 'package:eureka/ask.dart';
import 'package:eureka/assessmentscreen.dart';
import 'package:eureka/examscreen.dart';
import 'package:flutter/material.dart';

class Sidebar extends StatefulWidget {
  const Sidebar({super.key});

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
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
    return Row(
      children: [
        Container(
          width: 300,
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 2, 1, 16),
            border: Border(
              right: BorderSide(color: Colors.white, width: 1),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView(
              children: [
                const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    'Eureka',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Container(
                  decoration: BoxDecoration(
                    color:
                        _currentIndex == 0 ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.question_answer),
                    selectedColor: Colors.black,
                    selected: _currentIndex == 0,
                    title: const Text('Ask AI'),
                    onTap: () {
                      setState(() {
                        _currentIndex = 0;
                      });
                    },
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Container(
                  decoration: BoxDecoration(
                    color:
                        _currentIndex == 1 ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    selectedColor: Colors.black,
                    selected: _currentIndex == 1,
                    leading: const Icon(Icons.book),
                    title: const Text('Exams'),
                    onTap: () {
                      setState(() {
                        _currentIndex = 1;
                      });
                    },
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Container(
                  decoration: BoxDecoration(
                    color:
                        _currentIndex == 2 ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    selectedColor: Colors.black,
                    selected: _currentIndex == 2,
                    leading: const Icon(Icons.assessment),
                    title: const Text('Assessment'),
                    onTap: () {
                      setState(() {
                        _currentIndex = 2;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        Flexible(
          child: IndexedStack(
            index: _currentIndex,
            children: _children,
          ),
        )
      ],
    );
  }
}
