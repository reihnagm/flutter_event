class DateRangeModel {
  DateTime startDate;
  DateTime endDate;
  List<Map<String, dynamic>> dataArray;

  DateRangeModel({required this.startDate, required this.endDate, required this.dataArray});
}

Map<DateTime, List<Map<String, dynamic>>> groupDataByDate(List<DateRangeModel> data) {
  Map<DateTime, List<Map<String, dynamic>>> groupedData = {};

  for (var dateModel in data) {
    DateTime currentDate = dateModel.startDate;

    while (currentDate.isBefore(dateModel.endDate) || currentDate.isAtSameMomentAs(dateModel.endDate)) {
      groupedData.putIfAbsent(currentDate, () => []);
      groupedData[currentDate]!.addAll(dateModel.dataArray);
      currentDate = currentDate.add(const Duration(days: 1));
    }
  }

  return groupedData;
}

class EventModel {
  int status;
  bool error;
  String message;
  int total;
  int perPage;
  int prevPage;
  int nextPage;
  int currentPage;
  String nextUrl;
  String prevUrl;
  List<EventData> data;

  EventModel({
    required this.status,
    required this.error,
    required this.message,
    required this.total,
    required this.perPage,
    required this.prevPage,
    required this.nextPage,
    required this.currentPage,
    required this.nextUrl,
    required this.prevUrl,
    required this.data,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) => EventModel(
    status: json["status"],
    error: json["error"],
    message: json["message"],
    total: json["total"],
    perPage: json["per_page"],
    prevPage: json["prev_page"],
    nextPage: json["next_page"],
    currentPage: json["current_page"],
    nextUrl: json["next_url"],
    prevUrl: json["prev_url"],
    data: List<EventData>.from(json["data"].map((x) => EventData.fromJson(x))),
  );
}

class EventData {
  String id;
  String title;
  String caption;
  List<dynamic> media;
  DateTime startDate;
  DateTime endDate;
  String startTime;
  String endTime;
  User user;
  DateTime createdAt;

  EventData({
    required this.id,
    required this.title,
    required this.caption,
    required this.media,
    required this.startDate,
    required this.endDate,
    required this.startTime,
    required this.endTime,
    required this.user,
    required this.createdAt,
  });

  factory EventData.fromJson(Map<String, dynamic> json) => EventData(
    id: json["id"],
    title: json["title"],
    caption: json["caption"],
    media: List<dynamic>.from(json["media"].map((x) => x)),
    startDate: DateTime.parse(json["start_date"]),
    endDate: DateTime.parse(json["end_date"]),
    startTime: json["start_time"],
    endTime: json["end_time"],
    user: User.fromJson(json["user"]),
    createdAt: DateTime.parse(json["created_at"]),
  );
}

class User {
  String id;
  String fullname;

  User({
    required this.id,
    required this.fullname,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"],
    fullname: json["fullname"],
  );
}
