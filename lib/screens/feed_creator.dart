import '../common.dart';
import '../widgets/feeds_editor.dart';
import 'feeds_screen.dart';

class FeedCreator extends StatefulWidget {
  @override
  _FeedCreatorState createState() => _FeedCreatorState();
}

class _FeedCreatorState extends State<FeedCreator> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ArtBar(context, true, FeedsScreen()).bar(),
      body: Center(
        child: Scrollbar(
          child: SingleChildScrollView(
              child: Container(width: 508, child: FeedsEditor(null, 'create'))),
        ),
      ),
    );
  }
}
