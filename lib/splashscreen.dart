import 'package:eureka/main.dart';
import 'package:flutter/material.dart';

String apiKey = "";

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  TextEditingController textFieldController = TextEditingController();
  bool loading = false;
  @override
  void initState() {
    super.initState();
  }

  void _showInputDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
              'Go to https://aistudio.google.com/app/apikey and get you API to continue'),
          content: TextField(
            controller: textFieldController,
            decoration: const InputDecoration(hintText: "Gemini Key"),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Submit'),
              onPressed: () {
                if (textFieldController.text.isEmpty) {
                  // Show an error message if the input is invalid
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Please enter a valid Gemini Key')),
                  );
                } else {
                  Navigator.of(context).pop();
                  setState(() {
                    apiKey = textFieldController.text;
                    loading = true;
                  });
                  _navigateToHome();
                }
              },
            ),
          ],
        );
      },
    );
  }

  _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 1), () {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MyApp()),
      );
    });
    setState(() {
      splash = false;
    });
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Color.fromARGB(255, 19, 200, 217), // Start color
              Color.fromARGB(255, 8, 5, 45), // End color
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  _showInputDialog(context);
                },
                child: loading
                    ? const CircularProgressIndicator()
                    : const Text('Add Gemini Key'),
              ),
              Image.asset(
                'assets/images/logo.png',
                width: 100,
                height: 100,
              ),
              const SizedBox(height: 20),
              const Text(
                'Eureka',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
