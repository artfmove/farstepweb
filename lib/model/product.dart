
class Product {
  final String productId;

  List<dynamic> title;
  String price;
  List<dynamic> images;
  List<dynamic> description;
  List<dynamic> type;
  Product(
      {this.productId,
      this.title,
      this.price,
      this.images,
      this.description,
      this.type});
}
