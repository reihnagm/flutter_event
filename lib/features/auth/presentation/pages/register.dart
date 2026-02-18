import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutter_event/snackbar.dart';

import 'package:flutter_event/common/helpers/enum.dart';
import 'package:flutter_event/common/utils/color_resources.dart';
import 'package:flutter_event/common/utils/custom_themes.dart';

import 'package:flutter_event/features/event/presentation/pages/event_list.dart';
import 'package:flutter_event/features/auth/presentation/provider/register_notifier.dart';

class RegisterPage extends StatefulWidget {
  static const String route = '/register';

  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => RegisterPageState();
}

class RegisterPageState extends State<RegisterPage> {
  final formKey = GlobalKey<FormState>();

  late RegisterNotifier registerNotifier;

  bool obscure = false;

  Future<void> register() async {
    if (formKey.currentState!.validate()) {
      await registerNotifier.register();

      if (registerNotifier.state == ProviderState.error) {
        ShowSnackbar.snackbarErr(registerNotifier.message);
        return;
      } else {
        if (mounted) {
          Navigator.pushReplacementNamed(context, EventListPage.route);
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();

    registerNotifier = context.read<RegisterNotifier>();

    registerNotifier.fullnameC = TextEditingController();
    registerNotifier.emailC = TextEditingController();
    registerNotifier.passwordC = TextEditingController();
  }

  @override
  void dispose() {
    registerNotifier.fullnameC.dispose();
    registerNotifier.emailC.dispose();
    registerNotifier.passwordC.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorResources.background,
      appBar: AppBar(
        forceMaterialTransparency: true,
        centerTitle: true,
        title: Text(
          "Register",
          style: montserratRegular.copyWith(
            fontSize: 14.0,
            fontWeight: FontWeight.bold,
            color: ColorResources.black,
          ),
        ),
        leading: CupertinoNavigationBarBackButton(
          color: ColorResources.black,
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: RefreshIndicator.adaptive(
        color: ColorResources.black,
        onRefresh: () {
          return Future.sync(() {});
        },
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.only(top: 100.0, bottom: 15.0, left: 25.0, right: 25.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: registerNotifier.fullnameC,
                          cursorColor: ColorResources.black,
                          style: montserratRegular.copyWith(
                            fontSize: 12.0,
                            color: ColorResources.black,
                          ),
                          validator: (String? value) {
                            if (value!.isEmpty) {
                              return 'fullname cannot be empty';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: "Fullname",
                            labelStyle: montserratRegular.copyWith(
                              fontSize: 12.0,
                              color: ColorResources.black,
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: ColorResources.black),
                            ),
                            enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: ColorResources.black),
                            ),
                            border: const OutlineInputBorder(
                              borderSide: BorderSide(color: ColorResources.black),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20.0),

                        TextFormField(
                          controller: registerNotifier.emailC,
                          cursorColor: ColorResources.black,
                          style: montserratRegular.copyWith(
                            fontSize: 12.0,
                            color: ColorResources.black,
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
                              color: ColorResources.black,
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: ColorResources.black),
                            ),
                            enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: ColorResources.black),
                            ),
                            border: const OutlineInputBorder(
                              borderSide: BorderSide(color: ColorResources.black),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20.0),

                        TextFormField(
                          controller: registerNotifier.passwordC,
                          cursorColor: ColorResources.black,
                          style: montserratRegular.copyWith(
                            fontSize: 12.0,
                            color: ColorResources.black,
                          ),
                          validator: (String? value) {
                            if (value!.isEmpty) {
                              return 'password cannot be empty';
                            }
                            return null;
                          },
                          obscureText: obscure,
                          decoration: InputDecoration(
                            suffixIcon: InkWell(
                              onTap: () {
                                setState(() {
                                  obscure = !obscure;
                                });
                              },
                              child: obscure
                                  ? const Icon(Icons.visibility_off)
                                  : const Icon(Icons.visibility),
                            ),
                            labelText: "Password",
                            labelStyle: montserratRegular.copyWith(
                              fontSize: 12.0,
                              color: ColorResources.black,
                            ),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: ColorResources.black),
                            ),
                            enabledBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: ColorResources.black),
                            ),
                            border: const OutlineInputBorder(
                              borderSide: BorderSide(color: ColorResources.black),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25.0),

                  ElevatedButton(
                    onPressed: register,
                    child: Text(
                      'Register',
                      style: montserratRegular.copyWith(
                        fontSize: 14.0,
                        color: ColorResources.black,
                      ),
                    ),
                  ),

                  const SizedBox(height: 15.0),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Already have an account ?",
                        style: montserratRegular.copyWith(
                          fontSize: 12.0,
                          color: ColorResources.black,
                        ),
                      ),

                      const SizedBox(height: 10),

                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          "Login",
                          style: montserratRegular.copyWith(
                            fontSize: 12.0,
                            color: ColorResources.black,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
