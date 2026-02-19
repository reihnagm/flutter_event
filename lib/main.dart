import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:flutter_event/common/utils/custom_themes.dart';
import 'package:flutter_event/common/helpers/storage.dart';

import 'package:flutter_event/injection.dart';
import 'package:flutter_event/features/splash/presentation/pages/splash.dart';

import 'package:flutter_event/global.dart';
import 'package:flutter_event/providers.dart';
import 'package:flutter_event/route.dart';

// ✅ import gate
import 'package:flutter_event/common/permissions/permission_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await initializeDateFormatting("id_ID", null);
  Intl.defaultLocale = "id_ID";

  await StorageHelper.init();

  init();

  runApp(
    MultiProvider(
      providers: providers,
      child: const PermissionGate(child: MyApp()),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Event',
      supportedLocales: const [Locale('id', 'ID'), Locale('en', 'US')],
      locale: const Locale('id', 'ID'),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
      ],
      scaffoldMessengerKey: scaffoldKey,
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Montserrat',
        datePickerTheme: DatePickerThemeData(
          dayStyle: montserratRegular.copyWith(fontSize: 13.0),
          yearStyle: montserratRegular.copyWith(fontSize: 13.0),
          weekdayStyle: montserratRegular.copyWith(fontSize: 13.0),
        ),
        timePickerTheme: TimePickerThemeData(
          helpTextStyle: montserratRegular.copyWith(fontSize: 13.0),
          dayPeriodTextStyle: montserratRegular.copyWith(fontSize: 13.0),
          dialTextStyle: montserratRegular.copyWith(fontSize: 13.0),
        ),
        useMaterial3: true,
      ),
      onGenerateRoute: AppRoute.controller,
      initialRoute: SplashPage.route,
    );
  }
}
