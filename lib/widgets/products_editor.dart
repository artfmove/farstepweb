import '../common.dart';
import '../data.dart';
import '../model/product.dart';
import 'grid_images.dart';
import './delete_dialog.dart';
import './add_dialog.dart';
import 'expanded_type.dart';
import 'gallery.dart';
import 'validator_error.dart';
import '../screens/products_screen.dart';
import './text_form.dart';
import './expanded_text_form.dart';

class ProductsEditor extends StatefulWidget {
  final Product product;
  final String isCreate;

  ProductsEditor(
    this.product,
    this.isCreate,
  );
  @override
  _ProductsEditorState createState() => _ProductsEditorState();
}

class _ProductsEditorState extends State<ProductsEditor> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  AppLocalizations loc;
  String validatorType = '';
  String validatorImages = '';
  Product changedProduct;

  void _sendData() async {
    if (!_formKey.currentState.validate())
      return;
    else if (changedProduct.type == null)
      setState(() => validatorType = loc.choose_sorts);
    else if (changedProduct.images.length == 0) {
      setState(() => validatorImages = loc.no_image);
      return;
    } else {
      showDialog(
          context: context,
          builder: (ctx) => AddDialog(context, ctx,
                  widget.isCreate == 'create' ? loc.product_added : loc.changed,
                  () async {
                return widget.isCreate == 'create'
                    ? await Data().uploadNewProduct(changedProduct)
                    : await Data().uploadChangedProduct(changedProduct);
              }, ProductsScreen()));
    }
  }

  void _deleteProduct() {
    showDialog(
        context: context,
        builder: (ctx) =>
            DeleteDialog(context, ctx, loc.sure_want_delete_product, () async {
              return await Data().deleteProduct(changedProduct);
            }, ProductsScreen()));
  }

  @override
  void initState() {
    if (widget.isCreate == 'create')
      changedProduct = new Product(
        productId: '',
        title: ['', ''],
        description: ['', ''],
        images: [],
        price: '',
        type: null,
      );
    else if (widget.isCreate == 'current') changedProduct = widget.product;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    loc = AppLocalizations.of(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isCreate == 'current') changedProduct = widget.product;

    return Scrollbar(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(right: 20),
        child: Form(
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
                  ExpForm(changedProduct.title[0], (v) {
                    changedProduct.title[0] = v;
                  }, loc.title_rus, loc.enter_title_rus),
                  ExpForm(changedProduct.title[1], (v) {
                    changedProduct.title[1] = v;
                  }, loc.title_ukr, loc.enter_title_rus)
                ],
              ),
              TextForm(changedProduct.price, (v) {
                changedProduct.price = v;
              }, loc.price, loc.enter_price),
              ExpandedType(changedProduct.type, (List<dynamic> type) {
                changedProduct.type = type;
              }),
              ValidatorError(validatorType),
              Row(
                children: [
                  ExpForm(changedProduct.description[0], (v) {
                    changedProduct.description[0] = v;
                  }, loc.descr_rus, loc.enter_descr_rus),
                  ExpForm(changedProduct.description[1], (v) {
                    changedProduct.description[1] = v;
                  }, loc.descr_ukr, loc.enter_descr_ukr)
                ],
              ),
              GridImages(
                loc.in_order,
                changedProduct.images,
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
                                (list) => setState(
                                    () => changedProduct.images = list),
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
              Center(
                  child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: widget.isCreate == 'current'
                      ? MainAxisAlignment.spaceAround
                      : MainAxisAlignment.center,
                  children: [
                    widget.isCreate == 'current'
                        ? TextButton(
                            onPressed: () {
                              _deleteProduct();
                            },
                            child: Text(loc.delete))
                        : Container(),
                    ElevatedButton(
                        onPressed: () {
                          _sendData();
                        },
                        child: Text(widget.isCreate == 'create'
                            ? loc.add
                            : loc.change_info)),
                  ],
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}
