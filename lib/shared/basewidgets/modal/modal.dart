import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_event/common/helpers/enum.dart';
import 'package:flutter_event/common/helpers/storage.dart';

import 'package:flutter_event/common/utils/color_resources.dart';
import 'package:flutter_event/common/utils/custom_themes.dart';
import 'package:flutter_event/features/auth/presentation/pages/login.dart';
import 'package:flutter_event/features/event/presentation/provider/event_delete_notifier.dart';
import 'package:flutter_event/features/event/presentation/provider/event_list_notifier.dart';

import 'package:flutter_event/global.dart';
import 'package:flutter_event/shared/basewidgets/button/custom.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class GDialog {
  static Future<void> logout() {
    return showGeneralDialog(
      context: navigatorKey.currentState!.context,
      barrierLabel: "Barrier",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 700),
      pageBuilder: (BuildContext context, Animation<double> double, _) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.all(20.0),
              height: 250.0,
              decoration: BoxDecoration(
                color: ColorResources.white,
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Text(
                      "Are you sure want to Log out ?",
                      style: montserratRegular.copyWith(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w600,
                        color: ColorResources.black,
                      ),
                    ),
                  ),

                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 20.0, bottom: 20.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              const Expanded(child: SizedBox()),

                              Expanded(
                                flex: 5,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    "No",
                                    style: montserratRegular.copyWith(
                                      fontSize: 12.0,
                                      color: ColorResources.black,
                                    ),
                                  ),
                                ),
                              ),

                              const Expanded(child: SizedBox()),

                              Expanded(
                                flex: 5,
                                child: ElevatedButton(
                                  onPressed: () {
                                    StorageHelper.removeToken();
                                    Navigator.pushReplacementNamed(context, LoginPage.route);
                                  },
                                  child: Text(
                                    "Yes",
                                    style: montserratRegular.copyWith(
                                      fontSize: 12.0,
                                      color: ColorResources.black,
                                    ),
                                  ),
                                ),
                              ),

                              const Expanded(child: SizedBox()),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder:
          (BuildContext context, Animation<double> anim1, Animation<double> anim2, Widget? child) {
            Tween<Offset> tween;
            if (anim1.status == AnimationStatus.reverse) {
              tween = Tween(begin: const Offset(-1, 0), end: Offset.zero);
            } else {
              tween = Tween(begin: const Offset(1, 0), end: Offset.zero);
            }
            return SlideTransition(
              position: tween.animate(anim1),
              child: FadeTransition(opacity: anim1, child: child),
            );
          },
    );
  }

  static Future<void> requestPermission({
    required String msg,
    required String type,
    required String img,
  }) {
    return showDialog(
      context: navigatorKey.currentContext!,
      builder: (BuildContext context) {
        return PopScope(
          canPop: false,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 290.0,
                    height: 280.0,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          left: 20.0,
                          right: 20.0,
                          bottom: 20.0,
                          child: Container(
                            height: 200.0,
                            padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25.0),
                              color: Colors.white,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  msg,
                                  textAlign: TextAlign.center,
                                  style: montserratRegular.copyWith(
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w600,
                                    color: ColorResources.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        Positioned(
                          top: 15.0,
                          left: 50.0,
                          right: 50.0,
                          child: Container(
                            padding: EdgeInsets.all(15.0),
                            decoration: BoxDecoration(
                              boxShadow: kElevationToShadow[4],
                              color: ColorResources.white,
                              shape: BoxShape.circle,
                            ),
                            child: Image.asset("assets/images/$img", height: 50.0),
                          ),
                        ),

                        Positioned(
                          bottom: 40.0,
                          left: 80.0,
                          right: 80.0,
                          child: CustomButton(
                            isBorder: false,
                            btnColor: ColorResources.blue,
                            btnTextColor: Colors.white,
                            fontSize: 12.0,
                            sizeBorderRadius: 8.0,
                            isBorderRadius: true,
                            height: 30.0,
                            onTap: () async {
                              switch (type) {
                                case "notification":
                                  await AppSettings.openAppSettings(
                                    type: AppSettingsType.notification,
                                  );
                                  break;
                                case "photos":
                                  openAppSettings();
                                  break;
                                default:
                              }

                              Future.delayed(Duration.zero, () {
                                Navigator.pop(context);
                              });
                            },
                            btnTxt: "Izinkan",
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static Future<void> eventDelete({required String id}) {
    return showDialog(
      context: navigatorKey.currentContext!,
      builder: (BuildContext context) {
        return PopScope(
          canPop: false,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 290.0,
                    height: 280.0,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          left: 20.0,
                          right: 20.0,
                          bottom: 20.0,
                          child: Container(
                            height: 200.0,
                            padding: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25.0),
                              color: Colors.white,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  "Are you sure want to delete this event ?",
                                  textAlign: TextAlign.center,
                                  style: montserratRegular.copyWith(
                                    fontSize: 12.0,
                                    fontWeight: FontWeight.w600,
                                    color: ColorResources.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        Positioned(
                          bottom: 40.0,
                          left: 80.0,
                          right: 80.0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: CustomButton(
                                  isBorder: true,
                                  btnColor: Colors.white,
                                  btnTextColor: ColorResources.black,
                                  fontSize: 12.0,
                                  sizeBorderRadius: 8.0,
                                  isBorderRadius: true,
                                  height: 30.0,
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  btnTxt: "Cancel",
                                ),
                              ),
                              const SizedBox(width: 12.0),
                              Expanded(
                                child: CustomButton(
                                  isBorder: false,
                                  btnColor: ColorResources.error,
                                  btnTextColor: Colors.white,
                                  fontSize: 12.0,
                                  sizeBorderRadius: 8.0,
                                  isBorderRadius: true,
                                  height: 30.0,
                                  onTap: () {
                                    EventDeleteNotifier eventDeleteNotifier = context
                                        .read<EventDeleteNotifier>();
                                    EventListNotifier eventListNotifier = context
                                        .read<EventListNotifier>();

                                    Future.delayed(Duration.zero, () async {
                                      await eventDeleteNotifier.eventDelete(id: id);
                                    });

                                    Future.delayed(const Duration(seconds: 1), () async {
                                      await eventListNotifier.eventList();
                                    });

                                    Navigator.pop(context, "refetch");
                                  },
                                  isLoading:
                                      context.watch<EventDeleteNotifier>().state ==
                                          ProviderState.loading
                                      ? true
                                      : false,
                                  btnTxt: "Delete",
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  static Future<dynamic> quillToolbar({required QuillController controller}) {
    return showModalBottomSheet(
      context: navigatorKey.currentContext!,
      builder: (BuildContext context) {
        return QuillSimpleToolbar(
          controller: controller,
          config: const QuillSimpleToolbarConfig(
            showSuperscript: false,
            showSubscript: false,
            showCodeBlock: false,
            showAlignmentButtons: true,
            toolbarIconAlignment: WrapAlignment.spaceAround,
          ),
        );
      },
    );
  }
}
