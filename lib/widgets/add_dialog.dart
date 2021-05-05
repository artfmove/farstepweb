import '../common.dart';

class AddDialog extends StatefulWidget {
  final BuildContext context;
  final BuildContext ctx;
  final String content;
  final Function function;
  final dynamic screen;
  AddDialog(this.context, this.ctx, this.content, this.function, this.screen);
  @override
  _AddDialogState createState() => _AddDialogState();
}

class _AddDialogState extends State<AddDialog> {
  bool isLoading = true;
  Future future;

  @override
  void initState() {
    future = widget.function();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return FutureBuilder(
        future: future,
        builder: (context, snapshot) {
          return snapshot.connectionState == ConnectionState.waiting
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : snapshot.data['success'] == true
                  ? AlertDialog(
                      content: Text(widget.content),
                      actions: [
                        TextButton(
                            onPressed: () {
                              ArtBar(widget.context, false, null)
                                  .navigateRemoved(widget.screen);
                            },
                            child: Text(loc.ok))
                      ],
                    )
                  : AlertDialog(
                      content: Text(snapshot.data['error'] == null
                          ? loc.error
                          : snapshot.data['error']),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(widget.ctx).pop();
                          },
                          child: Text(loc.ok),
                        )
                      ],
                    );
        });
  }
}
