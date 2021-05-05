import '../common.dart';

class GridImages extends StatelessWidget {
  final String text;
  final List<dynamic> images;

  GridImages(this.text, this.images);

  @override
  Widget build(BuildContext context) {
    return images != null && images.length != 0
        ? ListView(
            shrinkWrap: true,
            children: [
              Padding(
                padding: const EdgeInsets.all(14.0),
                child: Text(
                  text,
                  style: Theme.of(context).textTheme.headline6,
                ),
              ),
              images.length != 0
                  ? GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          crossAxisCount: 2,
                          childAspectRatio: 1.7),
                      padding: EdgeInsets.all(0),
                      shrinkWrap: true,
                      itemBuilder: (_, i) {
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            Image.network(
                              images[i],
                              width: 280,
                              height: 180,
                              fit: BoxFit.cover,
                            ),
                          ],
                        );
                      },
                      itemCount: images.length,
                    )
                  : Container(),
            ],
          )
        : Container();
  }
}
