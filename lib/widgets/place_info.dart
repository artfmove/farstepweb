import '../common.dart';
import 'package:provider/provider.dart';
import '../screens/place_info_screen.dart';
import '../model/place_info_model.dart';
import '../data.dart';
import '../widgets/expanded_types.dart';
import '../style.dart';
import '../widgets/grid_images.dart';
import '../widgets/gallery.dart';
import '../widgets/validator_error.dart';
import './expanded_text_form.dart';
import './text_form.dart';

class PlaceInfo extends StatefulWidget {
  final PlaceInfoModel placeInfoModel;
  PlaceInfo(this.placeInfoModel);
  @override
  _PlaceInfoState createState() => _PlaceInfoState();
}

class _PlaceInfoState extends State<PlaceInfo> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  PlaceInfoModel _editedPlaceInfoModel = new PlaceInfoModel();
  AppLocalizations loc;
  List<String> listCities;
  List<Map> listTypes;

  String validatorTypes = '',
      validatorImages = '',
      validatorNutrValue = '',
      validatorAddressDark = '',
      validatorAddressLight = '';

  void sendEditedInfo() {
    validatorTypes = '';
    validatorImages = '';
    validatorNutrValue = '';
    validatorAddressDark = '';
    validatorAddressLight = '';
    if (!_formKey.currentState.validate())
      return;
    else if (_editedPlaceInfoModel.types.length == 0)
      setState(() => validatorTypes = loc.choose_sorts_coupons);
    else if (_editedPlaceInfoModel.nutrValue == '')
      setState(() => validatorNutrValue = loc.no_image);
    else if (_editedPlaceInfoModel.addressImages[0] == '')
      setState(() {
        validatorAddressDark = loc.no_image;
      });
    else if (_editedPlaceInfoModel.addressImages[1] == '')
      setState(() {
        validatorAddressLight = loc.no_image;
      });
    else if (_editedPlaceInfoModel.images.length == 0)
      setState(() => validatorImages = loc.no_image);
    else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(loc.warning),
          content: Text(loc.data_will_change),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(loc.cancel),
            ),
            TextButton(
              onPressed: () async {
                LoadingDialog().showLoad(context);
                final wasSuccesful =
                    await Provider.of<Data>(context, listen: false)
                        .uploadChangedPlaceInfo(context, _editedPlaceInfoModel);
                LoadingDialog().dispLoad();
                Navigator.pop(context);
                FocusScope.of(context).unfocus();

                if (wasSuccesful)
                  ArtBar(context, false, null)
                      .navigateRemoved(PlaceInfoScreen());
                else
                  LoadingDialog().showError(context, loc.error);
              },
              child: Text(loc.confirm_changes),
            ),
          ],
        ),
      );
    }
  }

  @override
  void didChangeDependencies() {
    loc = AppLocalizations.of(context);
    _editedPlaceInfoModel = PlaceInfoModel(
        title: widget.placeInfoModel.title ?? ['', ''],
        time: widget.placeInfoModel.time ?? '',
        phone: widget.placeInfoModel.phone ?? '',
        site: widget.placeInfoModel.site ?? '',
        images: widget.placeInfoModel.images ?? [],
        address: widget.placeInfoModel.address ?? ['', ''],
        addressUrl: widget.placeInfoModel.addressUrl ?? ['', ''],
        addressImages: widget.placeInfoModel.addressImages ?? ['', ''],
        types: widget.placeInfoModel.types ?? [],
        nutrValue: widget.placeInfoModel.nutrValue ?? '');
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Container(
        width: 600,
        child: Wrap(
          alignment: WrapAlignment.center,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          runSpacing: 30,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Row(
                children: [
                  ExpForm(_editedPlaceInfoModel.title[0], (v) {
                    _editedPlaceInfoModel.title[0] = v;
                  }, loc.title_rus, loc.enter_title_rus),
                  ExpForm(_editedPlaceInfoModel.title[1], (v) {
                    _editedPlaceInfoModel.title[1] = v;
                  }, loc.title_ukr, loc.enter_title_ukr),
                ],
              ),
            ),
            TextFormField(
              key: UniqueKey(),
              initialValue: _editedPlaceInfoModel.site,
              decoration: CommonStyle.textFieldStyle(
                labelTextStr: loc.web_site,
              ),
              onChanged: (v) => _editedPlaceInfoModel.site = v,
            ),
            TextForm(_editedPlaceInfoModel.phone, (v) {
              _editedPlaceInfoModel.phone = v;
            }, loc.phone, loc.enter_phone),
            TextForm(_editedPlaceInfoModel.time, (v) {
              _editedPlaceInfoModel.time = v;
            }, loc.time_open, loc.enter_time_open),
            Row(
              children: [
                ExpForm(_editedPlaceInfoModel.address[0], (v) {
                  _editedPlaceInfoModel.address[0] = v;
                }, loc.address_rus, loc.enter_address_rus),
                ExpForm(_editedPlaceInfoModel.address[1], (v) {
                  _editedPlaceInfoModel.address[1] = v;
                }, loc.address_ukr, loc.enter_address_rus),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    key: UniqueKey(),
                    initialValue: _editedPlaceInfoModel.addressUrl[0],
                    decoration: CommonStyle.textFieldStyle(
                      labelTextStr: loc.link_address_android,
                    ),
                    validator: (v) => v == '' || v == null
                        ? loc.enter_link_address_android
                        : null,
                    onChanged: (v) => _editedPlaceInfoModel.addressUrl[0] = v,
                    maxLines: 1,
                  ),
                ),
                Expanded(
                  child: TextFormField(
                    key: UniqueKey(),
                    initialValue: _editedPlaceInfoModel.addressUrl[1],
                    decoration: CommonStyle.textFieldStyle(
                      labelTextStr: loc.link_address_ios,
                    ),
                    validator: (v) => v == '' || v == null
                        ? loc.enter_link_address_ios
                        : null,
                    onChanged: (v) => _editedPlaceInfoModel.addressUrl[1] = v,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
            ExpandedTypes(_editedPlaceInfoModel.types, (List<dynamic> list) {
              _editedPlaceInfoModel.types = list;
            }),
            ValidatorError(validatorTypes),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Text(
                        loc.nutr_value,
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      _editedPlaceInfoModel.nutrValue != ''
                          ? Image.network(
                              _editedPlaceInfoModel.nutrValue,
                              height: 150,
                              width: 150,
                              fit: BoxFit.cover,
                            )
                          : Container(),
                      ValidatorError(validatorNutrValue),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () => showDialog(
                        context: context,
                        builder: (ctx) => Gallery(
                            (list) => setState(() =>
                                _editedPlaceInfoModel.nutrValue = list[0]),
                            false,
                            false)),
                    child: Row(
                      children: [
                        Text(
                          loc.choose_image,
                          style: Theme.of(context).textTheme.bodyText2,
                        ),
                        Icon(Icons.image)
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    direction: Axis.vertical,
                    spacing: 15,
                    children: [
                      Text(
                        loc.address_image_rus,
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      _editedPlaceInfoModel.addressImages[0] != ''
                          ? Image.network(
                              _editedPlaceInfoModel.addressImages[0],
                              height: 150,
                              width: 150,
                              fit: BoxFit.cover,
                            )
                          : Container(),
                      ValidatorError(validatorAddressDark),
                      ElevatedButton(
                        onPressed: () => showDialog(
                            context: context,
                            builder: (ctx) => Gallery(
                                (list) => setState(() => _editedPlaceInfoModel
                                    .addressImages[0] = list[0]),
                                false,
                                true)),
                        child: Row(
                          children: [
                            Text(
                              loc.choose_image,
                              style: Theme.of(context).textTheme.bodyText2,
                            ),
                            Icon(Icons.image)
                          ],
                        ),
                      ),
                    ],
                  ),
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    direction: Axis.vertical,
                    spacing: 15,
                    children: [
                      Text(
                        loc.address_image_ukr,
                        style: Theme.of(context).textTheme.headline6,
                      ),
                      _editedPlaceInfoModel.addressImages[1] != ''
                          ? Image.network(
                              _editedPlaceInfoModel.addressImages[1],
                              height: 150,
                              width: 150,
                              fit: BoxFit.cover,
                            )
                          : Container(),
                      ValidatorError(validatorAddressLight),
                      ElevatedButton(
                        onPressed: () => showDialog(
                            context: context,
                            builder: (ctx) => Gallery(
                                (list) => setState(() => _editedPlaceInfoModel
                                    .addressImages[1] = list[0]),
                                false,
                                true)),
                        child: Row(
                          children: [
                            Text(
                              loc.choose_image,
                              style: Theme.of(context).textTheme.bodyText2,
                            ),
                            Icon(Icons.image)
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Divider(),
            GridImages(loc.profile_photo, _editedPlaceInfoModel.images),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(child: ValidatorError(validatorImages)),
                      ElevatedButton(
                        onPressed: () => showDialog(
                            context: context,
                            builder: (ctx) => new Gallery(
                                (list) => setState(
                                    () => _editedPlaceInfoModel.images = list),
                                false,
                                true)),
                        child: Row(
                          children: [
                            Text(
                              loc.choose_image,
                              style: Theme.of(context).textTheme.bodyText2,
                            ),
                            Icon(Icons.image)
                          ],
                        ),
                      ),
                    ],
                  )),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: ElevatedButton(
                  onPressed: () {
                    sendEditedInfo();
                  },
                  child: Text(
                    loc.change_info,
                    style: TextStyle(fontSize: 18),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
