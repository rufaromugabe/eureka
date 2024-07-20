import 'package:camera/camera.dart';
import 'package:eureka/assessmentscreen.dart';
import 'package:eureka/discuss.dart';
import 'package:eureka/examscreen.dart';
import 'package:eureka/splashscreen.dart';
import 'package:eureka/widgets/sidebar.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

CameraDescription? firstCamera;
Future<void> main() async {
  runApp(const MyApp());
}

bool splash = true;

const String apiKey = "AIzaSyDsOduZY0h0N2mlPDgjLNzoD2d10TDxaKs";

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  int _currentIndex = 0;
  final List<Widget> _children = [
    const DiscussAi(),
    const ExamScreen(),
    const AssessmentScreen(),
  ];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    bool showBottomNavBar = screenSize.width < 900;
    bool sidebar = screenSize.width > 900;

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(useMaterial3: true).copyWith(
          scaffoldBackgroundColor: const Color.fromARGB(255, 2, 1, 16),
          appBarTheme: const AppBarTheme(
            color: Color.fromARGB(255, 2, 1, 16),
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Color.fromARGB(255, 2, 1, 16),
          ),
        ),
        home: splash
            ? const SplashScreen()
            : Scaffold(
                body: sidebar
                    ? const Sidebar()
                    : IndexedStack(
                        index: _currentIndex,
                        children: _children,
                      ),
                bottomNavigationBar: showBottomNavBar
                    ? SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15.0, vertical: 15),
                          child: GNav(
                            rippleColor: Colors.grey[300]!,
                            hoverColor: Colors.grey[100]!,
                            gap: 8,
                            activeColor: Colors.black,
                            iconSize: 24,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            duration: const Duration(milliseconds: 400),
                            tabBackgroundColor: Colors.grey[100]!,
                            color: Colors.white,
                            tabs: const [
                              GButton(
                                icon: Icons.question_answer,
                                text: 'Dialog',
                              ),
                              GButton(
                                icon: Icons.book,
                                text: 'Exams',
                              ),
                              GButton(
                                icon: Icons.assessment,
                                text: 'Assessment',
                              ),
                            ],
                            selectedIndex: _currentIndex,
                            onTabChange: (index) {
                              setState(() {
                                _currentIndex = index;
                              });
                            },
                          ),
                        ),
                      )
                    : null,
              ));
  }
}
