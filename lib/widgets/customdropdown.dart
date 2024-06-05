import 'package:flutter/material.dart';

class CustomDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const CustomDropdown(
      {super.key,
      required this.value,
      required this.items,
      required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: value,
      iconSize: 24,
      elevation: 10,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
      borderRadius: const BorderRadius.all(Radius.circular(20)),
      focusColor: const Color.fromARGB(255, 1, 4, 19),
      dropdownColor: const Color.fromARGB(255, 1, 4, 19),
      items: items.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}
