import '../common.dart';
import 'package:provider/provider.dart';
import '../model/place_info_model.dart';
import '../data.dart';
import '../widgets/place_info.dart';

class PlaceInfoScreen extends StatefulWidget {
  @override
  _PlaceInfoScreenState createState() => _PlaceInfoScreenState();
}

class _PlaceInfoScreenState extends State<PlaceInfoScreen> {
  PlaceInfoModel _placeInfoModel = new PlaceInfoModel();

  Future fetchInfo;

  @override
  void didChangeDependencies() {
    fetchInfo = Provider.of<Data>(context).loadPlaceInfo();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: ArtBar(context, false, null).bar(),
        body: Scrollbar(
            child: SingleChildScrollView(
          child: FutureBuilder(
              future: fetchInfo,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting ||
                    !snapshot.hasData ||
                    snapshot.data == null)
                  return Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.only(top: 300),
                    child: CircularProgressIndicator(),
                  );
                else {
                  _placeInfoModel = PlaceInfoModel(
                      title: snapshot.data.title ?? '',
                      time: snapshot.data.time ?? '',
                      phone: snapshot.data.phone ?? '',
                      site: snapshot.data.site ?? '',
                      images: snapshot.data.images ?? [],
                      address: snapshot.data.address ?? '',
                      addressUrl: snapshot.data.addressUrl ?? ['', ''],
                      addressImages: snapshot.data.addressImages ?? ['', ''],
                      types: Data().getTypes ?? {},
                      nutrValue: snapshot.data.nutrValue ?? '');
                  return Center(child: PlaceInfo(_placeInfoModel));
                }
              }),
        )));
  }
}
