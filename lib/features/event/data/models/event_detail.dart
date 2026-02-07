
import 'dart:io';

class EventDetailModel {
  int status;
  bool error;
  String message;
  EventDetailData data;

  EventDetailModel({
    required this.status,
    required this.error,
    required this.message,
    required this.data,
  });

  factory EventDetailModel.fromJson(Map<String, dynamic> json) => EventDetailModel(
    status: json["status"],
    error: json["error"],
    message: json["message"],
    data: EventDetailData.fromJson(json["data"]),
  );
}

class EventDetailData {
  String? id;
  String? title;
  String? caption;
  List<Media>? media;
  String? startDate;
  String? endDate;
  String? startTime;
  String? endTime;
  User? user;
  DateTime? createdAt;

  EventDetailData({
    this.id,
    this.title,
    this.caption,
    this.media,
    this.startDate,
    this.endDate,
    this.startTime,
    this.endTime,
    this.user,
    this.createdAt,
  });

  factory EventDetailData.fromJson(Map<String, dynamic> json) => EventDetailData(
    id: json["id"],
    title: json["title"],
    caption: json["caption"],
    media: List<Media>.from(json["media"].map((x) => Media.fromJson(x))),
    startDate: json["start_date"],
    endDate: json["end_date"],
    startTime: json["start_time"],
    endTime: json["end_time"],
    user: User.fromJson(json["user"]),
    createdAt: DateTime.parse(json["created_at"]),
  );

}

class Media {
  int id;
  String path;
  String type;
  File? file;

  Media({
    required this.id,
    required this.path,
    required this.type,
    required this.file
  });

  factory Media.fromJson(Map<String, dynamic> json) => Media(
    id: json["id"],
    path: json["path"],
    type: "network",
    file: null
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
