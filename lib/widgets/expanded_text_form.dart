import 'package:flutter/material.dart';
import '../style.dart';

class ExpForm extends StatelessWidget {
  final String initValue;
  final Function function;
  final String valid;
  final String label;
  ExpForm(this.initValue, this.function, this.label, this.valid);
  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: 1,
      child: TextFormField(
        key: UniqueKey(),
        maxLines: null,
        initialValue: initValue,
        validator: (v) => (v == '' || v == null) ? valid : null,
        decoration: CommonStyle.textFieldStyle(labelTextStr: label),
        onChanged: (v) {
          function(v);
        },
      ),
    );
  }
}
