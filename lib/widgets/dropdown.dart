import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../main.dart';

/// Hellgrüne Fläche der Auswahl-Chips (passend zu [maincolor]).
const Color dropdownChipColor = Color(0xFFE3EFE3);

/// Auswahl als runder "Pill"-Chip: hellgrüne Fläche, grüne Schrift,
/// optionales Icon davor und ein Pfeil nach unten.
class CustomDropdownButton extends StatelessWidget {
  const CustomDropdownButton(this.list, this.index, this.func,
      {this.icon, super.key});
  final List<String> list;
  final int index;
  final void Function(int) func;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    // Avoid duplicate strings which would occur in unrealistic cases.
    for (var i = 1; i < list.length; i++) {
      if (list[i].trim() == list[i - 1].trim()) list[i] = list[i - 1] + " ";
    }

    final textStyle = GoogleFonts.lato(
        color: maincolor, fontSize: 14, fontWeight: FontWeight.bold);

    return Container(
      height: 36,
      padding: EdgeInsets.only(left: icon == null ? 14 : 10, right: 6),
      decoration: BoxDecoration(
        color: dropdownChipColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (icon != null) ...[
          Icon(icon, size: 18, color: maincolor),
          SizedBox(width: 6),
        ],
        DropdownButtonHideUnderline(
          child: DropdownButton<int>(
            value: index,
            isDense: true,
            icon: const Icon(Icons.keyboard_arrow_down, color: maincolor),
            iconSize: 22,
            elevation: 4,
            borderRadius: BorderRadius.circular(12),
            dropdownColor: Colors.white,
            menuMaxHeight: 400,
            style: textStyle,
            onChanged: (int? value) {
              if (value != null) func(value);
            },
            // Ausgewählter Wert im Chip.
            selectedItemBuilder: (context) => list
                .map((value) => Align(
                    alignment: Alignment.centerLeft,
                    child: Text(value, style: textStyle)))
                .toList(),
            // Einträge in der aufgeklappten Liste.
            items: list.map<DropdownMenuItem<int>>((String value) {
              final i = list.indexOf(value);
              return DropdownMenuItem<int>(
                value: i,
                child: Text(value,
                    style: GoogleFonts.lato(
                        color: i == index ? maincolor : Colors.black87,
                        fontSize: 14,
                        fontWeight:
                            i == index ? FontWeight.bold : FontWeight.normal)),
              );
            }).toList(),
          ),
        ),
      ]),
    );
  }
}
