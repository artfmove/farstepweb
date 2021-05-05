import '../common.dart';
import '../widgets/products_list.dart';
import '../screens/product_creator.dart';
import '../widgets/navigate_button.dart';

class ProductsScreen extends StatefulWidget {
  @override
  _ProductsScreenState createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
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
              NavigateButton(context, loc.create_new_product, ProductCreator()),
              NavigateButton(context, loc.current_products, ProductsList()),
            ],
          ),
        ),
      ),
    );
  }
}
