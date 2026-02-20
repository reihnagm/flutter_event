import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'package:flutter_event/injection.dart';

import 'package:flutter_event/features/profile/presentation/provider/profile_notifier.dart';
import 'package:flutter_event/features/event/presentation/provider/event_delete_image_notifier.dart';
import 'package:flutter_event/features/event/presentation/provider/event_delete_notifier.dart';
import 'package:flutter_event/features/event/presentation/provider/event_detail_notifier.dart';
import 'package:flutter_event/features/event/presentation/provider/event_update_notifier.dart';
import 'package:flutter_event/features/event/presentation/provider/event_store_image_notifier.dart';
import 'package:flutter_event/features/event/presentation/provider/event_store_notifier.dart';
import 'package:flutter_event/features/auth/presentation/provider/login_notifier.dart';
import 'package:flutter_event/features/auth/presentation/provider/register_notifier.dart';
import 'package:flutter_event/features/event/presentation/provider/event_list_notifier.dart';

List<SingleChildWidget> providers = [
  ...independentServices,
];

List<SingleChildWidget> independentServices = [
  ChangeNotifierProvider(create: (_) => locator<RegisterNotifier>()),
  ChangeNotifierProvider(create: (_) => locator<LoginNotifier>()),
  ChangeNotifierProvider(create: (_) => locator<EventListNotifier>()),
  ChangeNotifierProvider(create: (_) => locator<EventStoreNotifier>()),
  ChangeNotifierProvider(create: (_) => locator<EventDeleteNotifier>()),
  ChangeNotifierProvider(create: (_) => locator<EventUpdateNotifier>()),
  ChangeNotifierProvider(create: (_) => locator<EventDetailNotifier>()),
  ChangeNotifierProvider(create: (_) => locator<EventStoreImageNotifier>()),
  ChangeNotifierProvider(create: (_) => locator<EventDeleteImageNotifier>()),
  ChangeNotifierProvider(create: (_) => locator<ProfileNotifier>()),
];