import 'package:flutter/material.dart';

class CustomDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  CustomDropdown(
      {required this.value, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: value,
      iconSize: 24,
      elevation: 10,
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 1),
      borderRadius: BorderRadius.all(Radius.circular(20)),
      focusColor: Color.fromARGB(255, 1, 4, 19),
      dropdownColor: Color.fromARGB(255, 1, 4, 19),
      underline: Container(decoration: BoxDecoration(color: Colors.blue)),
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
