import '../common.dart';
import '../widgets/coupon_item.dart';
import '../data.dart';
import '../model/coupon.dart';
import '../widgets/coupons_editor.dart';
import 'coupons_screen.dart';

class ListCoupons extends StatefulWidget {
  final bool isScheduled;
  ListCoupons(this.isScheduled);
  @override
  _ListCouponsState createState() => _ListCouponsState();
}

class _ListCouponsState extends State<ListCoupons> {
  Coupon chosenCoupon = Coupon(couponId: 'impossibleId');

  void toggleEditCoupon(Coupon coupon) {
    chosenCoupon = coupon;
    setState(() {});
  }

  Future loadCurrentCoupons;
  Future loadScheduledCoupons;

  @override
  void initState() {
    if (widget.isScheduled)
      loadScheduledCoupons = Data().loadScheduledCoupons();
    else
      loadCurrentCoupons = Data().loadCurrentCoupons();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      appBar: ArtBar(context, true, CouponsScreen()).bar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            FutureBuilder<List<Coupon>>(
                future: widget.isScheduled
                    ? loadScheduledCoupons
                    : loadCurrentCoupons,
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return CircularProgressIndicator();
                  else {
                    return Container(
                      width: 800,
                      child: Column(
                        children: [
                          Text(
                            widget.isScheduled
                                ? loc.scheduled_coupons
                                : loc.current_coupons,
                            style: Theme.of(context).textTheme.headline6,
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemBuilder: (_, i) {
                                return Row(
                                  children: [
                                    Container(
                                      color: chosenCoupon.couponId ==
                                              snapshot.data[i].couponId
                                          ? Colors.red
                                          : Colors.transparent,
                                      child: CouponItem(
                                          snapshot.data[i], toggleEditCoupon),
                                    ),
                                    widget.isScheduled
                                        ? Column(
                                            children: [
                                              Text(
                                                loc.active_in,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headline5,
                                              ),
                                              Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Text(
                                                      snapshot.data[i]
                                                          .stringStartDate
                                                          .toString(),
                                                      style: TextStyle(
                                                          color: Colors.red))),
                                              Text(
                                                loc.finish,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headline5,
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        8, 20, 8, 0),
                                                child: Text(
                                                  snapshot.data[i]
                                                      .stringExpirationDate
                                                      .toString(),
                                                  style: TextStyle(
                                                      color: Colors.red),
                                                ),
                                              ),
                                            ],
                                          )
                                        : Container()
                                  ],
                                );
                              },
                              itemCount: snapshot.data.length,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                }),
            chosenCoupon.couponId != 'impossibleId'
                ? Scrollbar(
                    child: SingleChildScrollView(
                      child: Container(
                        width: 510,
                        child: new CouponsEditor(chosenCoupon,
                            widget.isScheduled ? 'scheduled' : 'current'),
                      ),
                    ),
                  )
                : Container(
                    width: 510,
                  ),
          ],
        ),
      ),
    );
  }
}
