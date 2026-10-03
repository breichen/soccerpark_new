import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';

class CustomDropdownButton extends StatelessWidget {
  const CustomDropdownButton(this.list, this.index, this.func);
  final List<String> list;
  final int index;
  final void Function(int) func;

  @override
  Widget build(BuildContext context) {
    // Avoid duplicate strings which would occur in unrealistic cases.
    for (var i = 1; i < list.length; i++) {
      if (list[i].trim() == list[i - 1].trim()) list[i] = list[i - 1] + " ";
    }

    return DropdownButton<int>(
      value: index,
      icon: const Icon(Icons.arrow_downward, color: Color(mainredValue)),
      elevation: 16,
      style: GoogleFonts.lato(color: Color(mainredValue)),
      underline: Container(
        height: 2,
        color: mainred,
      ),
      onChanged: (int? value) {
        if (value != null) func(value);
      },
      items: list.map<DropdownMenuItem<int>>((String value) {
        return DropdownMenuItem<int>(
          value: list.indexOf(value),
          child: Text(value),
        );
      }).toList(),
    );
  }
}
