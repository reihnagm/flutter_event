class AuthModel {
  int status;
  bool error;
  String message;
  AuthData data;

  AuthModel({
    required this.status,
    required this.error,
    required this.message,
    required this.data,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) => AuthModel(
    status: json["status"],
    error: json["error"],
    message: json["message"],
    data: AuthData.fromJson(json["data"]),
  );
}

class AuthData {
  String token;

  AuthData({
    required this.token,
  });

  factory AuthData.fromJson(Map<String, dynamic> json) => AuthData(
    token: json["token"],
  );
}
