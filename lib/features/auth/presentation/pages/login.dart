import 'package:flutter/material.dart';
import 'package:flutter_event/features/event/presentation/pages/event_list.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'dart:developer' as dev;

import 'package:flutter_event/shared/basewidgets/modal/modal.dart';
import 'package:flutter_event/snackbar.dart';

import 'package:flutter_event/common/helpers/enum.dart';
import 'package:flutter_event/common/utils/color_resources.dart';
import 'package:flutter_event/common/utils/custom_themes.dart';

import 'package:flutter_event/features/auth/presentation/pages/register.dart';
import 'package:flutter_event/features/auth/presentation/provider/login_notifier.dart';

class LoginPage extends StatefulWidget {
  static const String route = '/login';

  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {

  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  late LoginNotifier loginNotifier;

  bool isDialogShowing = false; 

  Future<void> requestAllPermissions() async {
    if (isDialogShowing) return; // Prevent re-entry
    isDialogShowing = true;

    dev.log("=== REQUESTING PERMISSIONS ===");

    if (await requestPermission(Permission.notification, "notification", "notification.png")) return;

    dev.log("ALL PERMISSIONS GRANTED");
    isDialogShowing = false;
  }
  
  Future<bool> requestPermission(Permission permission, String type, String img) async {
    var status = await permission.request();

    if(type == "notification") {
      if (status ==  PermissionStatus.denied || status == PermissionStatus.permanentlyDenied) {
        await showDialog("Perizinan akses $type dibutuhkan, silahkan aktifkan terlebih dahulu", type, img);
        isDialogShowing = false;
        return true;
      }
    } else {
      if (status == PermissionStatus.permanentlyDenied) {
        await showDialog("Perizinan akses $type dibutuhkan, silahkan aktifkan terlebih dahulu", type, img);
        isDialogShowing = false;
        return true;
      }

      if (status != PermissionStatus.granted) {
        dev.log("Permission $type denied, stopping process.");
        isDialogShowing = false;
        return true; 
      }
    }
 
    return false; 
  }

  Future<void> showDialog(String message, String type, String img) async {
    if (!isDialogShowing) return;
    await GDialog.requestPermission(
      msg: message, 
      type: type, 
      img: img
    );
  }

  bool isVisible = false;

  Future<void> login() async {
    if(formKey.currentState!.validate()) {
      await loginNotifier.login();

      if(loginNotifier.state == ProviderState.error) {
        ShowSnackbar.snackbarErr(loginNotifier.message);
        return;
      } else {
        
        if(mounted) {
          Navigator.pushReplacementNamed(context, EventListPage.route);
        }
      }
       
    }
  }

  @override 
  void initState() {
    super.initState();

    requestAllPermissions();

    loginNotifier = context.read<LoginNotifier>();

    loginNotifier.emailC = TextEditingController();
    loginNotifier.passC = TextEditingController();
  }

  @override
  void dispose() {

    loginNotifier.emailC.dispose();
    loginNotifier.passC.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorResources.background,
      appBar: AppBar(
        forceMaterialTransparency: true,
        centerTitle: true,
        title: Text("Login",
         style: montserratRegular.copyWith(
            color: ColorResources.black,
            fontSize: 14.0
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: RefreshIndicator.adaptive(
        onRefresh: () {
          return Future.sync(() {});  
        },
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          slivers: [

            SliverPadding(
              padding: const EdgeInsets.only(
                top: 100.0,
                bottom: 15.0,
                left: 25.0,
                right: 25.0
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([

                  Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [

                        TextFormField(
                          controller: loginNotifier.emailC,
                          cursorColor: ColorResources.black,
                          style: montserratRegular.copyWith(
                            fontSize: 12.0,
                            color: ColorResources.black
                          ),
                          validator: (String? value) {
                            if (value!.isEmpty) {
                              return 'e-mail cannot be empty';
                            }

                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: "E-mail",
                            labelStyle: montserratRegular.copyWith(
                              fontSize: 12.0,
                              color: ColorResources.black
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                                color: ColorResources.black
                              )
                            ),
                            enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                                color: ColorResources.black
                              )
                            ),
                            border: const OutlineInputBorder(
                              borderSide: BorderSide(
                                color: ColorResources.black
                              )
                            )
                          ),
                        ),

                        const SizedBox(height: 20.0),

                        TextFormField(
                          controller: loginNotifier.passC,
                          cursorColor: ColorResources.black,
                          style: montserratRegular.copyWith(
                            fontSize: 12.0,
                            color: ColorResources.black
                          ),
                          validator: (String? value) {
                            if (value!.isEmpty) {
                              return 'password cannot be empty';
                            }

                            return null;
                          },
                          obscureText: isVisible,
                          decoration: InputDecoration(
                            labelText: "Password",
                            labelStyle: montserratRegular.copyWith(
                              fontSize: 12.0,
                              color: ColorResources.black
                            ),
                            suffixIcon: GestureDetector(
                              onTap: () {
                                setState(() {
                                  isVisible = !isVisible;
                                });
                              }, 
                              child: Icon(
                                isVisible 
                                ? Icons.visibility_off  
                                : Icons.visibility,
                                size: 20.0,
                                color: ColorResources.black,
                              ),
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                                color: ColorResources.black
                              )
                            ),
                            enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                                color: ColorResources.black
                              )
                            ),
                            border: const OutlineInputBorder(
                              borderSide: BorderSide(
                                color: ColorResources.black
                              )
                            )
                          ),
                        ),

                      ],
                    )
                  ),

                  const SizedBox(height: 25.0),

                  Consumer<LoginNotifier>(
                    builder: (BuildContext context, LoginNotifier notifier, Widget? child) {
                      return ElevatedButton(
                        onPressed: login,
                        child: notifier.state == ProviderState.loading 
                        ? const SizedBox(
                            width: 18.0,
                            height: 18.0,
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : Text('Login',
                          style: montserratRegular.copyWith(
                            fontSize: 14.0,
                            color: ColorResources.black,
                          ),
                        )
                      );
                    },
                  ),     
                  
                  const SizedBox(height: 15.0),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
      
                    Text("Don't have an account ?",
                      style: montserratRegular.copyWith(
                        fontSize: 12.0,
                        color: ColorResources.black,
                      ),
                    ),
      
                    const SizedBox(height: 10),
      
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, RegisterPage.route);
                      },
                      child: Text("Register",
                        style: montserratRegular.copyWith(
                          fontSize: 12.0,
                          color: ColorResources.black,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    )
      
                  ],
                )

                ])
              ),
            )

          ],
        )
      )
    );
  }
}