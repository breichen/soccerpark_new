import 'package:flutter/material.dart';

import '../main.dart';

class CustomCheckbox extends StatelessWidget {
  final bool checked;
  final void Function(bool?) func;

  CustomCheckbox(this.checked, this.func);

  @override
  Widget build(BuildContext context) {
    return Checkbox(
        checkColor: Colors.white,
        fillColor: MaterialStateProperty.resolveWith(getColor),
        value: checked,
        onChanged: func);
  }

  Color getColor(Set<MaterialState> states) {
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
    };
    if (states.any(interactiveStates.contains)) {
      return Colors.grey;
    }
    return maincolor;
  }
}
