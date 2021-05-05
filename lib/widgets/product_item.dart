import 'package:flutter/material.dart';
import '../model/product.dart';

class ProductItem extends StatefulWidget {
  final Product product;
  final Function function;
  ProductItem(this.product, this.function);
  @override
  _ProductItemState createState() => _ProductItemState();
}

class _ProductItemState extends State<ProductItem> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.function(widget.product);
      },
      child: Container(
        child: Card(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              FadeInImage.assetNetwork(
                width: 250,
                height: 250,
                placeholder: '../assets/images/loading.png',
                image: widget.product.images[0],
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
                    Text(widget.product.title[0],
                        textAlign: TextAlign.end,
                        style: TextStyle(fontSize: 28)),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        '${widget.product.price}грн.',
                        style: TextStyle(
                            fontSize: 24,
                            color: Theme.of(context).primaryColor),
                      ),
                    ),
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
