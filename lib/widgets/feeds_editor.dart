import '../common.dart';
import '../data.dart';
import '../screens/feeds_screen.dart';
import '../model/feed.dart';
import 'grid_images.dart';
import './add_dialog.dart';
import './delete_dialog.dart';
import 'gallery.dart';
import 'package:date_time_picker/date_time_picker.dart';
import 'validator_error.dart';
import './expanded_text_form.dart';

class FeedsEditor extends StatefulWidget {
  final Feed feed;
  final String isCreate;

  FeedsEditor(
    this.feed,
    this.isCreate,
  );
  @override
  _FeedsEditorState createState() => _FeedsEditorState();
}

class _FeedsEditorState extends State<FeedsEditor> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  bool uploadRightNow = false;
  AppLocalizations loc;
  String validatorType = '';
  String validatorImages = '';
  Feed changedFeed;
  Feed oldCoupon = new Feed();

  void _sendData() async {
    if (!_formKey.currentState.validate())
      return;
    else if (changedFeed.images.length == 0) {
      setState(() => validatorImages = loc.no_image);
      return;
    } else {
      showDialog(
          context: context,
          builder: (ctx) => AddDialog(context, ctx,
                  widget.isCreate == 'create' ? loc.add : loc.changed,
                  () async {
                return widget.isCreate == 'create'
                    ? await Data().uploadNewFeed(changedFeed)
                    : await Data()
                        .uploadChangedFeed(changedFeed, widget.isCreate);
              }, FeedsScreen()));
    }
  }

  void _deleteFeed() {
    showDialog(
        context: context,
        builder: (ctx) =>
            DeleteDialog(context, ctx, loc.sure_want_delete_feed, () async {
              return await Data()
                  .deleteFeedFunction(changedFeed, widget.isCreate);
            }, FeedsScreen()));
  }

  @override
  void initState() {
    if (widget.isCreate == 'create')
      changedFeed = new Feed(
        feedId: '',
        title: ['', ''],
        description: ['', ''],
        images: [],
        startDate: DateTime.now(),
      );
    super.initState();
  }

  @override
  void didChangeDependencies() {
    loc = AppLocalizations.of(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    print(widget.isCreate);

    if (widget.isCreate == 'scheduled' || widget.isCreate == 'current')
      changedFeed = widget.feed;

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
              ExpForm(changedFeed.title[0], (v) {
                changedFeed.title[0] = v;
              }, loc.title_rus, loc.enter_title_rus),
              ExpForm(changedFeed.title[1], (v) {
                changedFeed.title[1] = v;
              }, loc.title_ukr, loc.enter_title_ukr)
            ],
          ),
          Row(
            children: [
              ExpForm(changedFeed.description[0], (v) {
                changedFeed.description[0] = v;
              }, loc.descr_rus, loc.enter_descr_rus),
              ExpForm(changedFeed.description[1], (v) {
                changedFeed.description[1] = v;
              }, loc.descr_ukr, loc.enter_descr_ukr)
            ],
          ),
          GridImages(
            loc.in_order,
            changedFeed.images,
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
                            (list) => setState(() => changedFeed.images = list),
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
            initialDate: changedFeed.startDate,
            initialDatePickerMode: DatePickerMode.day,
            initialValue: changedFeed.startDate.toIso8601String(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2100),
            locale: Locale('ru'),
            icon: Icon(Icons.add_alarm),
            dateLabelText: loc.date,
            timeLabelText: loc.time,
            selectableDayPredicate: (date) {
              return true;
            },
            enabled: widget.isCreate == 'create' ? true : false,
            onChanged: (val) {
              changedFeed.startDate = DateTime.parse(val);
            },
            validator: (val) {
              if (val.isEmpty && widget.isCreate == 'create')
                return loc.select_date;
              return null;
            },
            onSaved: (val) => {},
          ),
          Center(
              child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (widget.isCreate != 'create')
                  TextButton(
                      onPressed: () {
                        _deleteFeed();
                      },
                      child: Text(loc.delete)),
                ElevatedButton(
                    onPressed: () {
                      _sendData();
                    },
                    child: Text(widget.isCreate == 'create'
                        ? loc.add_feed
                        : loc.change_feed)),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
