// gradient_app_bar.dart
import 'package:flutter/material.dart';

class GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String titleText;
  final List<Color> gradientColors;
  final Alignment beginAlignment;
  final Alignment endAlignment;

  const GradientAppBar({
    super.key,
    required this.titleText,
    this.gradientColors = const [
      Color.fromARGB(255, 49, 49, 77),
      Color.fromARGB(255, 2, 1, 16),
    ],
    this.beginAlignment = Alignment.bottomLeft,
    this.endAlignment = Alignment.bottomRight,
  });

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight), // Default is 56.0
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: beginAlignment,
            end: endAlignment,
          ),
        ),
        child: AppBar(
          title: Text(titleText),
          backgroundColor: Colors.transparent,
          elevation: 0, //
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
