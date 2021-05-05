import '../common.dart';
import '../widgets/feed_item.dart';
import '../data.dart';
import '../model/feed.dart';
import '../widgets/feeds_editor.dart';
import 'feeds_screen.dart';

class FeedsList extends StatefulWidget {
  final bool isScheduled;
  FeedsList(this.isScheduled);
  @override
  _FeedsListState createState() => _FeedsListState();
}

class _FeedsListState extends State<FeedsList> {
  Feed chosenFeed = Feed(feedId: 'impossibleId');

  void toggleEditFeed(Feed feed) {
    chosenFeed = feed;
    setState(() {});
  }

  Future loadCurrentFeeds;
  Future loadScheduledFeeds;

  @override
  void initState() {
    widget.isScheduled
        ? loadScheduledFeeds = Data().loadScheduledFeeds()
        : loadCurrentFeeds = Data().loadCurrentFeeds();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AppLocalizations loc = AppLocalizations.of(context);
    return Scaffold(
      appBar: ArtBar(context, true, FeedsScreen()).bar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            FutureBuilder<List<Feed>>(
                future:
                    widget.isScheduled ? loadScheduledFeeds : loadCurrentFeeds,
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return CircularProgressIndicator();
                  else {
                    return Container(
                      width: 800,
                      child: Column(
                        children: [
                          Text(
                            widget.isScheduled
                                ? loc.scheduled_feeds
                                : loc.current_feeds,
                            style: Theme.of(context).textTheme.headline6,
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemBuilder: (_, i) {
                                return Row(
                                  children: [
                                    Container(
                                      color: chosenFeed.feedId ==
                                              snapshot.data[i].feedId
                                          ? Colors.red
                                          : Colors.transparent,
                                      //padding: EdgeInsets.all(50),
                                      child: FeedItem(
                                          snapshot.data[i], toggleEditFeed),
                                    ),
                                  ],
                                );
                              },
                              itemCount: snapshot.data.length,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                }),
            chosenFeed.feedId != 'impossibleId'
                ? Scrollbar(
                    child: SingleChildScrollView(
                      child: Container(
                        width: 510,
                        child: new FeedsEditor(chosenFeed,
                            widget.isScheduled ? 'scheduled' : 'current'),
                      ),
                    ),
                  )
                : Container(
                    width: 510,
                  ),
          ],
        ),
      ),
    );
  }
}
