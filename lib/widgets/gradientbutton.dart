import 'package:flutter/material.dart';

class GradientButton extends StatelessWidget {
  final IconData iconData;
  final String tooltip;
  final VoidCallback onPressed;
  final double width;
  final double height;

  const GradientButton({
    super.key,
    required this.iconData,
    required this.tooltip,
    required this.onPressed,
    this.width = 100,
    this.height = 100,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      hoverColor: Colors.deepPurple.withOpacity(0.2),
      onTap: onPressed,
      child: Container(
        width: width,
        height: height,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 105, 55, 140), // Start color
              Color.fromARGB(255, 10, 5, 72), // End color
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              tooltip: tooltip,
              icon: Icon(iconData),
              onPressed: onPressed,
            ),
            Text(tooltip) // Using tooltip as button label for simplicity
          ],
        ),
      ),
    );
  }
}
