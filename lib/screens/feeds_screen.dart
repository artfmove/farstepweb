import '../common.dart';
import '../screens/feed_creator.dart';
import '../screens/feeds_list.dart';
import '../widgets/navigate_button.dart';

class FeedsScreen extends StatefulWidget {
  @override
  _FeedsScreenState createState() => _FeedsScreenState();
}

class _FeedsScreenState extends State<FeedsScreen> {
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      appBar: ArtBar(context, false, null).bar(),
      body: Center(
        child: Container(
          height: 800,
          child: Wrap(
            alignment: WrapAlignment.center,
            runAlignment: WrapAlignment.center,
            spacing: 50,
            runSpacing: 50,
            children: [
              NavigateButton(context, loc.create_new_feed, FeedCreator()),
              NavigateButton(context, loc.current_feeds, FeedsList(false)),
              NavigateButton(context, loc.scheduled_feeds, FeedsList(true)),
            ],
          ),
        ),
      ),
    );
  }
}
