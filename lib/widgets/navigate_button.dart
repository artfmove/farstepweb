import '../common.dart';

class NavigateButton extends StatelessWidget {
  final BuildContext context;
  final String text;
  final dynamic screen;
  NavigateButton(this.context, this.text, this.screen);
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        ArtBar(context, false, null).navigate(screen);
      },
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Text(text, style: Theme.of(context).textTheme.headline6),
      ),
    );
  }
}
