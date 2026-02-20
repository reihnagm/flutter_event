import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:flutter_event/global.dart';
import 'package:flutter_event/shared/basewidgets/modal/modal.dart';

class PermissionGate extends StatefulWidget {
  const PermissionGate({super.key, required this.child});

  final Widget child;

  /// Bisa dipakai dari page manapun (misalnya LoginPage) buat re-check.
  static Future<void> ensurePermissions({bool requestIfDenied = true}) async {
    await PermissionManager.instance.ensurePermissions(requestIfDenied: requestIfDenied);
  }

  @override
  State<PermissionGate> createState() => PermissionGateState();
}

class PermissionGateState extends State<PermissionGate> with WidgetsBindingObserver {
  DateTime? lastResumeCheck;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // request pertama kali setelah frame pertama
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await PermissionGate.ensurePermissions(requestIfDenied: true);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    dev.log("AppLifecycleState: $state");

    if (state == AppLifecycleState.resumed) {
      // anti spam saat resume beruntun
      final now = DateTime.now();
      if (lastResumeCheck != null && now.difference(lastResumeCheck!).inMilliseconds < 700) {
        return;
      }
      lastResumeCheck = now;

      await PermissionGate.ensurePermissions(requestIfDenied: true);
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class PermissionManager {
  PermissionManager._();
  static final PermissionManager instance = PermissionManager._();

  bool isDialogShowing = false;
  bool isEnsuring = false;

  /// Tambahin permission lain di list ini kalau perlu (camera, location, dll)
  final List<PermissionRequest> _permissions = const [
    PermissionRequest(
      permission: Permission.notification,
      type: "notification",
      img: "notification.png",
      message: "Perizinan akses notifikasi dibutuhkan agar kamu dapat menerima update event.",
    ),
    PermissionRequest(
      permission: Permission.photos,
      type: "photos",
      img: "media.png",
      message: "Perizinan akses photo dibutuhkan agar kamu dapat mengambil file.",
    ),
  ];

  Future<void> ensurePermissions({required bool requestIfDenied}) async {
    if (isEnsuring) return;
    isEnsuring = true;

    try {
      for (final req in _permissions) {
        await ensureSingle(req, requestIfDenied: requestIfDenied);
      }
    } finally {
      isEnsuring = false;
    }
  }

  Future<void> ensureSingle(PermissionRequest req, {required bool requestIfDenied}) async {
    final status = await req.permission.status;

    if (status.isGranted) return;

    // Permanently denied → suruh user aktifkan dari settings
    if (status.isPermanentlyDenied) {
      await showPermissionDialog(req);
      return;
    }

    // Denied → kalau disuruh request, request lagi
    if (requestIfDenied) {
      final newStatus = await req.permission.request();

      if (newStatus.isGranted) return;

      if (newStatus.isPermanentlyDenied) {
        await showPermissionDialog(req);
        return;
      }

      showSnack("Izin ${req.type} belum diberikan. Beberapa fitur mungkin tidak berfungsi.");
      return;
    }
  }

  Future<void> showPermissionDialog(PermissionRequest req) async {
    if (isDialogShowing) return;
    isDialogShowing = true;

    try {
      await GDialog.requestPermission(msg: req.message, type: req.type, img: req.img);
    } finally {
      isDialogShowing = false;
    }
  }

  void showSnack(String msg) {
    final messenger = scaffoldKey.currentState;
    if (messenger == null) return;

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(SnackBar(content: Text(msg), duration: const Duration(seconds: 2)));
  }
}

class PermissionRequest {
  final Permission permission;
  final String type;
  final String img;
  final String message;

  const PermissionRequest({
    required this.permission,
    required this.type,
    required this.img,
    required this.message,
  });
}
