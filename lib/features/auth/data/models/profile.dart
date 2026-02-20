class ProfileModel {
  int status;
  bool error;
  String message;
  ProfileData data;

  ProfileModel({
    required this.status,
    required this.error,
    required this.message,
    required this.data,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
    status: json["status"],
    error: json["error"],
    message: json["message"],
    data: ProfileData.fromJson(json["data"]),
  );
}

class ProfileData {
  int? id;
  String? userId;
  String? avatar;
  String? phone;
  String? fullname;
  String? email;

  ProfileData({this.id, this.userId, this.avatar, this.phone, this.fullname, this.email});

  factory ProfileData.fromJson(Map<String, dynamic> json) => ProfileData(
    id: json["id"],
    userId: json["user_id"],
    avatar: json["avatar"],
    phone: json["phone"],
    fullname: json["fullname"],
    email: json["email"],
  );
}
