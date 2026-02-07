import 'package:flutter/material.dart';

import 'package:flutter_event/common/helpers/storage.dart';
import 'package:flutter_event/features/auth/presentation/pages/login.dart';

import 'package:flutter_event/features/event/presentation/pages/event_list.dart';

class SplashPage extends StatefulWidget {
  static const String route = '/splash';

  const SplashPage({super.key});

  @override
  State<SplashPage> createState() =>SplashPageState();
}

class SplashPageState extends State<SplashPage> {

  @override 
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 1), () async {
      bool? isLoggedIn = await StorageHelper.isLoggedIn();

      if(isLoggedIn != null) {
        if(isLoggedIn) {
          if(mounted) {
            Navigator.pushNamed(context, EventListPage.route);
          }
        } else {
          if(mounted) {
            Navigator.pushReplacementNamed(context, LoginPage.route);
          }
        }
      } else {
        if(mounted) {
          Navigator.pushReplacementNamed(context, LoginPage.route);
        }
      }
    });
  }

  @override 
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Text("My Event",
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold
          ),
        )
      )
    );
  }
}