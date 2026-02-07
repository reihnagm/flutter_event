
import 'package:flutter/material.dart';

import 'package:flutter_event/features/auth/presentation/pages/login.dart';
import 'package:flutter_event/features/auth/presentation/pages/register.dart';
import 'package:flutter_event/features/event/presentation/pages/event_detail.dart';
import 'package:flutter_event/features/event/presentation/pages/event_list.dart';
import 'package:flutter_event/features/event/presentation/pages/form_create.dart';
import 'package:flutter_event/features/event/presentation/pages/form_edit.dart';
import 'package:flutter_event/features/splash/presentation/pages/splash.dart';

class AppRoute {

  static Route<dynamic>? controller(RouteSettings settings) {
    switch (settings.name) {
      case SplashPage.route:
        return MaterialPageRoute(builder: (context) => const SplashPage());
      case RegisterPage.route:
        return MaterialPageRoute(builder: (context) => const RegisterPage());
      case LoginPage.route:
        return MaterialPageRoute(builder: (context) => const LoginPage());
      case EventListPage.route:
        return MaterialPageRoute(builder: (context) => const EventListPage());
      case EventDetailPage.route:
        final data = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(builder: (context) => EventDetailPage(event: data["event"]));
      case FormEventCreatePage.route:
        return MaterialPageRoute(builder: (context) => const FormEventCreatePage());
      case FormEventEditPage.route:
        final data = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(builder: (context) => FormEventEditPage(id: data["id"]));
      default:
        return null;
    }
  }

}