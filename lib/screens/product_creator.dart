import '../common.dart';
import './products_screen.dart';
import '../widgets/products_editor.dart';

class ProductCreator extends StatefulWidget {
  @override
  _ProductCreatorState createState() => _ProductCreatorState();
}

class _ProductCreatorState extends State<ProductCreator> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: ArtBar(context, true, ProductsScreen()).bar(),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 510,
                child: ProductsEditor(null, 'create'),
              )
            ],
          ),
        ));
  }
}
