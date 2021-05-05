import '../common.dart';
import '../data.dart';
import '../model/coupon.dart';
import '../screens/list_coupons.dart';
import '../screens/coupons_screen.dart';
import './grid_images.dart';
import 'expanded_type.dart';
import './gallery.dart';
import 'package:date_time_picker/date_time_picker.dart';
import '../widgets/validator_error.dart';
import './delete_dialog.dart';
import './add_dialog.dart';
import './expanded_text_form.dart';

class CouponsEditor extends StatefulWidget {
  final Coupon coupon;
  final String isCreate;

  CouponsEditor(
    this.coupon,
    this.isCreate,
  );
  @override
  _CouponsEditorState createState() => _CouponsEditorState();
}

class _CouponsEditorState extends State<CouponsEditor> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool uploadRightNow = false;
  AppLocalizations loc;
  String validatorType = '';
  String validatorImages = '';
  Coupon changedCoupon;
  Coupon oldCoupon = new Coupon();

  void _sendData() async {
    if (!_formKey.currentState.validate())
      return;
    else if (changedCoupon.type == null)
      setState(() => validatorType = loc.choose_sorts);
    else if (changedCoupon.images.length == 0) {
      setState(() => validatorImages = loc.no_image);
      return;
    } else {
      if (widget.isCreate == 'create' || widget.isCreate == 'import') {
        showDialog(
          context: context,
          builder: (ctx) => AddDialog(context, ctx, loc.coupon_added, () async {
            return await Data().uploadNewCoupon(changedCoupon);
          }, CouponsScreen()),
        );
      } else {
        showDialog(
          context: context,
          builder: (ctx) =>
              AddDialog(context, ctx, loc.coupon_changed, () async {
            return await Data()
                .uploadChangedCoupon(changedCoupon, widget.isCreate);
          }, ListCoupons(widget.isCreate == 'scheduled' ? true : false)),
        );
      }
    }
  }

  void _deleteCoupon() {
    showDialog(
        context: context,
        builder: (ctx) =>
            DeleteDialog(context, ctx, loc.sure_delete_coupon, () async {
              return await Data().deleteCouponFunction(widget.isCreate,
                  changedCoupon.couponId, changedCoupon.expirationTask);
            }, ListCoupons(widget.isCreate == 'current' ? false : true)));
  }

  @override
  void initState() {
    if (widget.isCreate == 'create')
      changedCoupon = new Coupon(
        couponId: '',
        title: ['', ''],
        description: ['', ''],
        images: [],
        price: ['', ''],
        type: null,
        startDate: DateTime.now(),
        expirationDate: DateTime.now().add(Duration(days: 7)),
        expirationMinutes: '',
        restartHours: '',
      );
    else if (widget.isCreate == 'import')
      changedCoupon = widget.coupon;
    else if (widget.isCreate == 'scheduled' || widget.isCreate == 'current') {
      changedCoupon = widget.coupon;
      oldCoupon.startDate = widget.coupon.startDate;
      oldCoupon.expirationDate = widget.coupon.expirationDate;
    }
    super.initState();
  }

  @override
  void didChangeDependencies() {
    loc = AppLocalizations.of(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isCreate != 'create') changedCoupon = widget.coupon;
    return Form(
      key: _formKey,
      child: Wrap(
        spacing: 20,
        runSpacing: 20,
        children: [
          SizedBox(
            height: 20,
          ),
          Row(
            children: [
              ExpForm(changedCoupon.title[0], (v) {
                changedCoupon.title[0] = v;
              }, loc.title_rus, loc.enter_title_rus),
              ExpForm(changedCoupon.title[1], (v) {
                changedCoupon.title[1] = v;
              }, loc.title_ukr, loc.enter_title_ukr)
            ],
          ),
          Row(
            children: [
              ExpForm(changedCoupon.price[0], (v) {
                changedCoupon.price[0] = v;
              }, loc.price_before, loc.enter_price_before),
              ExpForm(changedCoupon.price[1], (v) {
                changedCoupon.price[1] = v;
              }, loc.price_after, loc.enter_price_after)
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(child: Text(loc.restart_after)),
              ExpForm(changedCoupon.restartHours, (v) {
                changedCoupon.restartHours = v;
              }, loc.hours, loc.hours),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(child: Text(loc.activity)),
              ExpForm(changedCoupon.expirationMinutes.toString(), (v) {
                changedCoupon.expirationMinutes = v;
              }, loc.minutes, loc.minutes),
            ],
          ),
          ExpandedType(changedCoupon.type, (List type) {
            changedCoupon.type = type;
          }),
          ValidatorError(validatorType),
          Row(
            children: [
              ExpForm(changedCoupon.description[0], (v) {
                changedCoupon.description[0] = v;
              }, loc.descr_rus, loc.enter_descr_rus),
              ExpForm(changedCoupon.description[1], (v) {
                changedCoupon.description[1] = v;
              }, loc.descr_ukr, loc.enter_descr_ukr)
            ],
          ),
          GridImages(
            loc.in_order,
            changedCoupon.images,
          ),
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
                        builder: (ctx) => Gallery(
                            (list) =>
                                setState(() => changedCoupon.images = list),
                            false,
                            true),
                      ),
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
          Text(loc.start_date, style: Theme.of(context).textTheme.headline6),
          DateTimePicker(
            key: UniqueKey(),
            type: DateTimePickerType.dateTimeSeparate,
            dateMask: 'd MMM, yyyy',
            initialDate: changedCoupon.startDate == null
                ? null
                : changedCoupon.startDate,
            initialValue: changedCoupon.startDate == null
                ? null
                : changedCoupon.startDate.toIso8601String(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
            locale: Locale('ru'),
            icon: Icon(Icons.add_alarm),
            dateLabelText: loc.date,
            timeLabelText: loc.time,
            selectableDayPredicate: (date) {
              return true;
            },
            enabled: widget.isCreate == 'create' || widget.isCreate == 'import'
                ? true
                : false,
            onChanged: (val) {
              changedCoupon.startDate = DateTime.parse(val);
            },
            validator: (val) {
              if (val.isEmpty && !uploadRightNow) return loc.select_date;
              return null;
            },
            onSaved: (val) => {},
          ),
          Text(
            loc.expiration_date,
            style: Theme.of(context).textTheme.headline6,
            textAlign: TextAlign.start,
          ),
          DateTimePicker(
            key: UniqueKey(),
            type: DateTimePickerType.dateTimeSeparate,
            dateMask: 'd MMM, yyyy',
            initialDate: changedCoupon.expirationDate == null
                ? null
                : changedCoupon.expirationDate,
            initialValue: changedCoupon.expirationDate == null
                ? null
                : changedCoupon.expirationDate.toIso8601String(),
            enabled: widget.isCreate == 'create' || widget.isCreate == 'import'
                ? true
                : false,
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
            locale: Locale('ru'),
            icon: Icon(Icons.access_alarm),
            dateLabelText: loc.date,
            timeLabelText: loc.time,
            selectableDayPredicate: (date) {
              return true;
            },
            onChanged: (val) {
              changedCoupon.expirationDate = DateTime.parse(val);
            },
            validator: (val) {
              if (val.isEmpty) return loc.select_date;
              return null;
            },
            onSaved: (val) {},
          ),
          Center(
              child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment:
                  widget.isCreate == 'scheduled' || widget.isCreate == 'current'
                      ? MainAxisAlignment.spaceAround
                      : MainAxisAlignment.center,
              children: [
                widget.isCreate == 'scheduled' || widget.isCreate == 'current'
                    ? TextButton(
                        onPressed: () {
                          _deleteCoupon();
                        },
                        child: Text(loc.delete))
                    : Container(),
                ElevatedButton(
                    onPressed: () {
                      _sendData();
                    },
                    child: Text(widget.isCreate == 'create' ||
                            widget.isCreate == 'import'
                        ? loc.create_coupon
                        : loc.change_data)),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
