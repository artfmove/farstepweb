import '../common.dart';

class DeleteDialog extends StatefulWidget {
  final BuildContext context;
  final BuildContext ctx;
  final String content;
  final Function function;
  final dynamic screen;

  DeleteDialog(
      this.context, this.ctx, this.content, this.function, this.screen);
  @override
  _DeleteDialogState createState() => _DeleteDialogState();
}

class _DeleteDialogState extends State<DeleteDialog> {
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : AlertDialog(
            content: Text(widget.content),
            title: Text(loc.deletion),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(widget.ctx).pop(),
                child: Text(loc.cancel),
              ),
              TextButton(
                onPressed: () async {
                  setState(() => isLoading = true);
                  final success = await widget.function();
                  setState(() => isLoading = false);
                  Navigator.of(widget.ctx).pop();
                  if (success) {
                    showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (_) => AlertDialog(
                              content: Text(loc.deleted),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      ArtBar(widget.context, false, null)
                                          .navigateRemoved(widget.screen);
                                    },
                                    child: Text(loc.ok))
                              ],
                            ));
                  } else {
                    showDialog(
                        context: context,
                        builder: (ctx2) => AlertDialog(
                              content: Text(loc.error_try_later),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(ctx2).pop();
                                  },
                                  child: Text(loc.ok),
                                )
                              ],
                            ));
                  }
                },
                child: Text(loc.yes_delete),
              )
            ],
          );
  }
}
