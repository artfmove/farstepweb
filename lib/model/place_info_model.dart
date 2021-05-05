class PlaceInfoModel {
  List<dynamic> title;
  String time;
  List<dynamic> address;
  List<dynamic> addressUrl;
  List<dynamic> addressImages;
  List<dynamic> images = [];
  String phone;
  String site;

  List<dynamic> types;
  String nutrValue;
  PlaceInfoModel(
      {this.title,
      this.time,
      this.address,
      this.addressUrl,
      this.images,
      this.addressImages,
      this.phone,
      this.site,
      this.types,
      this.nutrValue});
}
