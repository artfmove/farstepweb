import '../common.dart';

import '../data.dart';

class Gallery extends StatefulWidget {
  final Function chooseImage;
  final bool fromGallery;
  final bool allowMultiple;
  Gallery(this.chooseImage, this.fromGallery, this.allowMultiple);
  @override
  _GalleryState createState() => _GalleryState();
}

class _GalleryState extends State<Gallery> {
  List<String> chosenImages = [];
  List<dynamic> snapshotImages = [];
  int quantity = 0;
  AppLocalizations loc;
  Future loadGallery;
  @override
  void initState() {
    loadGallery = Data().loadGallery(widget.allowMultiple);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    loc = AppLocalizations.of(context);
    super.didChangeDependencies();
  }

  void showDeleteDialog(context, list, imageUrl) {
    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              content: Text(loc.sure_want_delete),
              actions: [
                TextButton(
                    onPressed: () async {
                      LoadingDialog().showLoad(context);
                      final success =
                          await Data().deleteImageFromGallery(list, imageUrl);
                      LoadingDialog().dispLoad();
                      if (success)
                        snapshotImages.remove(imageUrl);
                      else
                        LoadingDialog().showError(context, loc.error);
                      Navigator.of(ctx).pop();
                      setState(() {});
                    },
                    child: Text(loc.delete)),
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                  child: Text(loc.cancel),
                )
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: loadGallery,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());
          else {
            snapshotImages = snapshot.data;
            return Dialog(
              child: Container(
                width: 700,
                padding: EdgeInsets.only(bottom: 15),
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4, childAspectRatio: 1.5),
                      padding: EdgeInsets.all(0),
                      shrinkWrap: true,
                      itemBuilder: (_, i) {
                        return Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: TextButton(
                              onPressed: () {
                                setState(() {
                                  if (chosenImages.contains(snapshotImages[i]))
                                    chosenImages.remove(snapshotImages[i]);
                                  else if (widget.allowMultiple ||
                                      (!widget.allowMultiple &&
                                          chosenImages.length != 1))
                                    chosenImages.add(snapshotImages[i]);
                                });
                              },
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Image.network(
                                    snapshotImages[i],
                                    width: 200,
                                    fit: BoxFit.cover,
                                  ),
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: IconButton(
                                        icon: Icon(Icons.delete_forever),
                                        onPressed: () {
                                          showDeleteDialog(
                                            context,
                                            snapshotImages,
                                            snapshotImages[i],
                                          );
                                        }),
                                  ),
                                  chosenImages.contains(snapshotImages[i])
                                      ? Container(
                                          color: Colors.black54,
                                          width: 280,
                                          height: 180,
                                          child: Icon(Icons.check),
                                        )
                                      : Container(),
                                ],
                              ),
                            ));
                      },
                      itemCount: snapshotImages.length,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        TextButton(
                            onPressed: () async {
                              //LoadingDialog().showLoad(context);

                              final success = await Data().pickDiskImages(
                                  context, widget.allowMultiple);

                              if (!success)
                                LoadingDialog().showError(context, loc.error);
                              else {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                  content: Text(loc.new_photo_will_added),
                                ));
                                Navigator.of(context).pop();
                              }
                            },
                            child: Row(
                              children: [
                                Text(
                                  loc.add_photo_from_storage,
                                  style: Theme.of(context).textTheme.bodyText2,
                                ),
                                Icon(Icons.image)
                              ],
                            )),
                        if (!widget.fromGallery)
                          ElevatedButton(
                              onPressed: () {
                                widget.chooseImage(chosenImages);
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                  '${loc.choose_image} (${chosenImages.length})')),
                      ],
                    )
                  ],
                ),
              ),
            );
          }
        });
  }
}
