import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_event/shared/models/error.dart';

class ServerException implements Exception {
  final String message;

  ServerException(this.message);

  String getMessage() {
    return message;
  }
}

Future<String> handleHttpException({
  required Map<String, dynamic> data,
  required int statusCode,
})  async {
  String message = '';
  
  if(statusCode == 400) {

    final error = ErrorModel.fromJson(data);
    message = error.message;

  } else {
    if(statusCode == 401) {
      return message = "Kamu tidak diizinkan mengakses halaman ini";
    } else if(statusCode == 413) {
      return message = "Maksimal ukuran berkas 5 MB";
    } else if(statusCode == 403) {
      return message = "Anda tidak diizinkan mengakses halaman ini";
    } else if(statusCode == 500) {
      return message = "Sedang dalam gangguan";
    } else if(statusCode == 502) {
      return message= "Sedang dalam gangguan";
    } else {
      return message = "Sedang dalam gangguan"; 
    }
  }

  return message;
}

String handleDioException(DioException e) {
  String message = '';
  if (e.type == DioExceptionType.badResponse) {
    if(e.response?.statusCode == 400) {
      Map<String, dynamic> data = e.response?.data;
      message = data["message"];
    } else {
      if(e.response?.statusCode == 401) {
        return message = "Maksimal ukuran berkas 5 MB";
      } else if(e.response?.statusCode == 413) {
        return message = "Maksimal ukuran berkas 5 MB";
      } else if(e.response?.statusCode == 403) {
        return message = "Anda tidak diizinkan akses halaman ini";
      } else if(e.response?.statusCode == 405) {
        return message = "Halaman tidak ditemukan";
      } else if(e.response?.statusCode == 500) {
        return message = "Sedang dalam gangguan";
      } else if(e.response?.statusCode == 502) {
        return message= "Sedang dalam gangguan";
      } else {
        return message = "Sedang dalam gangguan"; 
      }
    }
    return message;
  } else {
    if (e.error is SocketException) {
      message = "Koneksi internetmu terganggu!";
    } else {
      message = (e.message ?? "Sedang dalam gangguan").toString();
    }
    return message;
  }
}
