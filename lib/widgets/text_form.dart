import 'package:flutter/material.dart';
import '../style.dart';

class TextForm extends StatelessWidget {
  final String initValue;
  final Function function;
  final String valid;
  final String label;
  TextForm(this.initValue, this.function, this.label, this.valid);
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: UniqueKey(),
      initialValue: initValue,
      validator: (v) => (v == '' || v == null) ? valid : null,
      decoration: CommonStyle.textFieldStyle(labelTextStr: label),
      onChanged: (v) {
        function(v);
      },
    );
  }
}
