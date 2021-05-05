import '../common.dart';
import '../widgets/coupons_editor.dart';
import 'package:provider/provider.dart';
import '../data.dart';
import '../model/coupon.dart';
import '../model/product.dart';
import 'coupons_screen.dart';

class CreatorCoupon extends StatefulWidget {
  @override
  _CreatorCouponState createState() => _CreatorCouponState();
}

class _CreatorCouponState extends State<CreatorCoupon> {
  Future _loadProducts;
  List<Product> listProducts = [];
  Coupon couponFromImport;
  AppLocalizations loc;

  @override
  void initState() {
    _loadProducts = Provider.of<Data>(context, listen: false).loadProducts();
    super.initState();
  }

  Coupon chooseFromProducts() {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        child: Container(
          width: 300,
          color: Colors.black54,
          child: listProducts.length == 0
              ? Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Text(loc.no_products),
                )
              : ListView.builder(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 20),
                  shrinkWrap: true,
                  itemBuilder: (_, i) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: TextButton(
                      onPressed: () {
                        couponFromImport = Coupon(
                            description: listProducts[i].description,
                            title: listProducts[i].title,
                            price: [listProducts[i].price, ''],
                            restartHours: '',
                            expirationMinutes: '',
                            type: listProducts[i].type,
                            images: listProducts[i].images);
                        setState(() {});
                        Navigator.of(ctx).pop();
                      },
                      child: Text(
                        listProducts[i].title[0],
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  itemCount: listProducts.length,
                ),
        ),
      ),
    );
    return couponFromImport;
  }

  @override
  Widget build(BuildContext context) {
    loc = AppLocalizations.of(context);
    return Scaffold(
      appBar: ArtBar(context, true, CouponsScreen()).bar(),
      body: Center(
        child: FutureBuilder(
            future: _loadProducts,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting ||
                  !snapshot.hasData)
                return CircularProgressIndicator();
              else {
                listProducts =
                    Provider.of<Data>(context, listen: false).getListProducts;
                return Scrollbar(
                  child: ListView(children: [
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                            onPressed: () {
                              chooseFromProducts();
                            },
                            child: Text(loc.import_product))
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                            width: 508,
                            child: couponFromImport == null
                                ? CouponsEditor(null, 'create')
                                : CouponsEditor(couponFromImport, 'import')),
                      ],
                    )
                  ]),
                );
              }
            }),
      ),
    );
  }
}
