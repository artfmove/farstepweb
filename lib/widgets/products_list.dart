import '../common.dart';
import '../model/product.dart';
import '../data.dart';
import '../widgets/product_item.dart';
import '../screens/products_screen.dart';
import '../widgets/products_editor.dart';

class ProductsList extends StatefulWidget {
  @override
  _ProductsListState createState() => _ProductsListState();
}

class _ProductsListState extends State<ProductsList> {
  Product chosenProduct = Product(productId: 'impossibleId');

  void toggleEditProduct(Product product) {
    setState(() => chosenProduct = product);
  }

  Future loadProducts;
  @override
  void initState() {
    loadProducts = Data().loadProducts();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: ArtBar(context, true, ProductsScreen()).bar(),
        body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  FutureBuilder<List<Product>>(
                      future: loadProducts,
                      builder: (context, snapshot) {
                        if (!snapshot.hasData)
                          return CircularProgressIndicator();
                        else {
                          return Container(
                            width: 800,
                            child: Column(
                              children: [
                                Text(
                                  AppLocalizations.of(context).current_products,
                                  style: Theme.of(context).textTheme.headline6,
                                ),
                                Expanded(
                                  child: ListView.builder(
                                    itemBuilder: (_, i) {
                                      return Row(
                                        children: [
                                          Container(
                                            color: chosenProduct.productId ==
                                                    snapshot.data[i].productId
                                                ? Colors.red
                                                : Colors.transparent,
                                            child: ProductItem(snapshot.data[i],
                                                toggleEditProduct),
                                          ),
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
                  chosenProduct.productId != 'impossibleId'
                      ? Scrollbar(
                          child: SingleChildScrollView(
                            child: Container(
                              width: 510,
                              child: ProductsEditor(chosenProduct, 'current'),
                            ),
                          ),
                        )
                      : Container(
                          width: 510,
                        ),
                ])));
  }
}
