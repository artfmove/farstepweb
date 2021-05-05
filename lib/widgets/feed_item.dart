import 'package:flutter/material.dart';
import '../model/feed.dart';

class FeedItem extends StatefulWidget {
  final Feed feed;
  final Function function;
  FeedItem(this.feed, this.function);
  @override
  _FeedItemState createState() => _FeedItemState();
}

class _FeedItemState extends State<FeedItem> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.function(widget.feed);
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
                image: widget.feed.images[0],
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
                    Text(widget.feed.title[0],
                        textAlign: TextAlign.end,
                        style: TextStyle(fontSize: 28)),
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
