import 'package:flutter/material.dart';
import '../model/coupon.dart';

class EditorImage extends StatelessWidget {
  var listImages;
  Coupon coupon;
  int i;
  EditorImage(this.listImages, this.coupon, this.i);
  @override
  Widget build(BuildContext context) {
    return Container(
      child: listImages != null
          ? Image.memory(
              listImages[i],
              fit: BoxFit.cover,
              height: 200,
              width: 200,
            )
          : Image.network(
              coupon.images[i],
              width: 200,
              height: 200,
            ),
    );
  }
}
