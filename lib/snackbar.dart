import 'package:flutter/material.dart';
import 'package:flutter_event/common/utils/color_resources.dart';
import 'package:flutter_event/common/utils/custom_themes.dart';
import 'package:flutter_event/global.dart';

class ShowSnackbar {
  ShowSnackbar._();

  static snackbarOk(String content) {
    ScaffoldMessenger.of(navigatorKey.currentState!.context).clearSnackBars();
    ScaffoldMessenger.of(navigatorKey.currentState!.context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,  
        backgroundColor: Colors.green,
        content: Text(
          content.contains('SocketException') ? "Koneksi internet anda tidak stabil. Pastikan anda terhubung ke internet." : content,
          style: montserratRegular.copyWith(
            color: ColorResources.white,
            fontSize: 13.0
          ),
        ),
        action: SnackBarAction(
          label: "",
          onPressed: () {
            ScaffoldMessenger.of(navigatorKey.currentState!.context).hideCurrentSnackBar();
          }
        ),
      )
    );
  }

  static snackbarErr(String content) {
    ScaffoldMessenger.of(navigatorKey.currentState!.context).clearSnackBars();
    ScaffoldMessenger.of(navigatorKey.currentState!.context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,  
        backgroundColor: Colors.red,
        content: Text(
          content.contains('SocketException') ? "Koneksi internet anda tidak stabil. Pastikan anda terhubung ke internet." : content,
          style: montserratRegular.copyWith(
            color: ColorResources.white,
            fontSize: 13.0
          ),
        ),
        action: SnackBarAction(
          label: "",
          onPressed: () {
            ScaffoldMessenger.of(navigatorKey.currentState!.context).hideCurrentSnackBar();
          }
        ),
      )
    );
  }

}