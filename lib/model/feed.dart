class Feed {
  String feedId;
  List<dynamic> title;
  List<dynamic> description;
  DateTime startDate;
  List<dynamic> images;
  final String startTask;
  final String expirationTask;

  Feed(
      {this.feedId,
      this.title,
      this.description,
      this.images,
      this.startDate,
      this.startTask,
      this.expirationTask});
}
