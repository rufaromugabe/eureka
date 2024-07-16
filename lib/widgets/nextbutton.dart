import 'package:flutter/material.dart';

class Nextbutton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  const Nextbutton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        gradient: const LinearGradient(
          colors: [
            Color.fromARGB(255, 26, 12, 104),
            Color.fromARGB(255, 88, 79, 167), // Add your gradient colors here
          ],
          begin: Alignment.topRight,
          end: Alignment.topLeft,
        ),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(8.0),
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        child: Text(text,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
