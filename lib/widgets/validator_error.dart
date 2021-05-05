import 'package:flutter/material.dart';

class ValidatorError extends StatelessWidget {
  final String text;
  ValidatorError(this.text);
  @override
  Widget build(BuildContext context) {
    return text != ''
        ? Padding(
            padding: const EdgeInsets.all(8.0),
            child:
                Text(text, style: TextStyle(color: Colors.red, fontSize: 15)),
          )
        : Container();
  }
}
