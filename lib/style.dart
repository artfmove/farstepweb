import 'package:flutter/material.dart';

class CommonStyle {
  static InputDecoration textFieldStyle(
      {String labelTextStr = '',
      String content,
      Function function,
      BuildContext context}) {
    return InputDecoration(
      isDense: true,
      fillColor: Colors.red,
      hoverColor: Colors.red,
      labelText: labelTextStr,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}
