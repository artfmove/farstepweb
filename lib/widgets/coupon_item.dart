import 'package:flutter/material.dart';
import '../model/coupon.dart';

class CouponItem extends StatefulWidget {
  final Coupon coupon;
  final Function function;
  CouponItem(this.coupon, this.function);
  @override
  _CouponItemState createState() => _CouponItemState();
}

class _CouponItemState extends State<CouponItem> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.function(widget.coupon);
      },
      child: Container(
        child: Card(
          //color: Colors.black,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              FadeInImage.assetNetwork(
                width: 250,
                height: 250,
                placeholder: '../assets/images/loading.png',
                image: widget.coupon.images[0],
                fit: BoxFit.cover,
              ),
              Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                padding: EdgeInsets.all(8),
                width: 250,
                height: 250,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(widget.coupon.title[0],
                        textAlign: TextAlign.end,
                        style: TextStyle(fontSize: 28)),
                    Align(
                        alignment: Alignment.bottomRight,
                        child: Text.rich(
                          TextSpan(
                            children: <TextSpan>[
                              new TextSpan(
                                text: '\$${widget.coupon.price[0]}',
                                style: new TextStyle(
                                  color: Colors.grey,
                                  fontSize: 18,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                              new TextSpan(
                                style: TextStyle(
                                    fontSize: 24,
                                    color: Theme.of(context).primaryColor),
                                text: ' \$${widget.coupon.price[1]}',
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
