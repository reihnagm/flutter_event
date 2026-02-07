import 'package:equatable/equatable.dart';

class ErrorModel extends Equatable {
  final int status;
  final bool error;
  final String message;

  const ErrorModel({
    required this.status,
    required this.error,
    required this.message,
  });

  @override
  List<Object?> get props => [status, error, message];

  factory ErrorModel.fromJson(Map<String, dynamic> json) => ErrorModel(
    status: json["status"],
    error: json["error"],
    message: json["message"],
  );
}
