class Coupon {
  final String couponId;
  List<dynamic> title;
  List<dynamic> images;
  List<dynamic> price;
  List<dynamic> description;
  DateTime startDate;
  DateTime expirationDate;
  String stringStartDate;
  String stringExpirationDate;
  List<dynamic> type;
  String restartHours;
  String expirationMinutes;

  final String expirationTask;

  Coupon(
      {this.couponId,
      this.title,
      this.images,
      this.price,
      this.description,
      this.startDate,
      this.expirationDate,
      this.type,
      this.stringStartDate,
      this.stringExpirationDate,
      this.expirationMinutes,
      this.restartHours,
      this.expirationTask});
}
