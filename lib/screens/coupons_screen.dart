import '../common.dart';
import '../screens/creator_coupon.dart';
import 'list_coupons.dart';
import '../widgets/navigate_button.dart';

class CouponsScreen extends StatefulWidget {
  @override
  _CouponsScreenState createState() => _CouponsScreenState();
}

class _CouponsScreenState extends State<CouponsScreen> {
  AppLocalizations loc;

  @override
  Widget build(BuildContext context) {
    loc = AppLocalizations.of(context);
    return Scaffold(
      appBar: ArtBar(context, false, null).bar(),
      body: Center(
        child: Container(
          height: 800,
          child: Wrap(
            alignment: WrapAlignment.center,
            runAlignment: WrapAlignment.center,
            spacing: 50,
            runSpacing: 50,
            children: [
              NavigateButton(context, loc.create_coupon, CreatorCoupon()),
              NavigateButton(context, loc.current_coupons, ListCoupons(false)),
              NavigateButton(context, loc.scheduled_coupons, ListCoupons(true)),
            ],
          ),
        ),
      ),
    );
  }
}
