import 'package:dio/dio.dart';

import 'package:get_it/get_it.dart';

import 'package:flutter_event/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:flutter_event/features/event/data/datasources/event_remote_data_source.dart';
import 'package:flutter_event/features/auth/data/datasources/auth_remote_data_source.dart';

import 'package:flutter_event/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_event/features/profile/domain/repositories/profile_repository.dart';
import 'package:flutter_event/features/event/domain/repositories/event_repository.dart';

import 'package:flutter_event/common/helpers/dio.dart';

import 'package:flutter_event/features/profile/domain/usecases/get_profile.dart';
import 'package:flutter_event/features/profile/domain/usecases/update_profile.dart';
import 'package:flutter_event/features/event/domain/usecases/event_delete.dart';
import 'package:flutter_event/features/event/domain/usecases/event_delete_image.dart';
import 'package:flutter_event/features/event/domain/usecases/event_detail.dart';
import 'package:flutter_event/features/event/domain/usecases/event_list.dart';
import 'package:flutter_event/features/event/domain/usecases/event_store.dart';
import 'package:flutter_event/features/event/domain/usecases/event_store_image.dart';
import 'package:flutter_event/features/event/domain/usecases/event_update.dart';
import 'package:flutter_event/features/auth/domain/usecases/login.dart';
import 'package:flutter_event/features/auth/domain/usecases/register.dart';

import 'package:flutter_event/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:flutter_event/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:flutter_event/features/event/data/repositories/event_repository_impl.dart';

import 'package:flutter_event/features/auth/presentation/provider/login_notifier.dart';
import 'package:flutter_event/features/profile/presentation/provider/profile_notifier.dart';
import 'package:flutter_event/features/auth/presentation/provider/register_notifier.dart';

import 'package:flutter_event/features/event/presentation/provider/event_delete_image_notifier.dart';
import 'package:flutter_event/features/event/presentation/provider/event_delete_notifier.dart';
import 'package:flutter_event/features/event/presentation/provider/event_detail_notifier.dart';
import 'package:flutter_event/features/event/presentation/provider/event_list_notifier.dart';
import 'package:flutter_event/features/event/presentation/provider/event_store_image_notifier.dart';
import 'package:flutter_event/features/event/presentation/provider/event_store_notifier.dart';
import 'package:flutter_event/features/event/presentation/provider/event_update_notifier.dart';

final locator = GetIt.instance;

void init() {
  _registerCore();
  _registerDataSources();
  _registerRepositories();
  _registerUseCases();
  _registerNotifiers();
}

/// Core / External
void _registerCore() {
  // Dio dibuat sekali (re-use). Timeout dll sudah kamu set di DioHelper.
  locator.registerLazySingleton<Dio>(() => DioHelper.shared.getClient());
}

/// Remote Data Source
void _registerDataSources() {
  locator.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(client: locator<Dio>()),
  );
  locator.registerLazySingleton<EventRemoteDataSource>(() => EventRemoteDataSourceImpl());
  locator.registerLazySingleton<ProfileRemoteDataSource>(() => ProfileRemoteDataSourceImpl());
}

/// Repository
void _registerRepositories() {
  locator.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: locator<AuthRemoteDataSource>()),
  );
  locator.registerLazySingleton<EventRepository>(
    () => EventRepositoryImpl(remoteDataSource: locator<EventRemoteDataSource>()),
  );
  locator.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(remoteDataSource: locator<ProfileRemoteDataSource>()),
  );
}

/// Use Case
void _registerUseCases() {
  locator.registerLazySingleton(() => RegisterUseCase(locator<AuthRepository>()));
  locator.registerLazySingleton(() => LoginUseCase(locator<AuthRepository>()));

  locator.registerLazySingleton(() => GetProfileUseCase(locator<ProfileRepository>()));
  locator.registerLazySingleton(() => UpdateProfileUseCase(locator<ProfileRepository>()));

  locator.registerLazySingleton(() => EventListUseCase(locator<EventRepository>()));
  locator.registerLazySingleton(() => EventDetailUseCase(locator<EventRepository>()));
  locator.registerLazySingleton(() => EventStoreUseCase(locator<EventRepository>()));
  locator.registerLazySingleton(() => EventUpdateUseCase(locator<EventRepository>()));
  locator.registerLazySingleton(() => EventStoreImageUseCase(locator<EventRepository>()));
  locator.registerLazySingleton(() => EventDeleteImageUseCase(locator<EventRepository>()));
  locator.registerLazySingleton(() => EventDeleteUseCase(locator<EventRepository>()));
}

/// Notifier
void _registerNotifiers() {
  locator.registerFactory(() => RegisterNotifier(registerUseCase: locator()));
  locator.registerFactory(() => LoginNotifier(loginUseCase: locator()));
  locator.registerFactory(() => ProfileNotifier(profileUseCase: locator()));

  locator.registerFactory(() => EventListNotifier(eventListUseCase: locator()));
  locator.registerFactory(() => EventDetailNotifier(eventDetailUseCase: locator()));
  locator.registerFactory(() => EventStoreNotifier(eventStoreUseCase: locator()));
  locator.registerFactory(() => EventUpdateNotifier(eventUpdateUseCase: locator()));
  locator.registerFactory(() => EventDeleteNotifier(eventDeleteUseCase: locator()));
  locator.registerFactory(() => EventStoreImageNotifier(eventStoreUseCase: locator()));
  locator.registerFactory(() => EventDeleteImageNotifier(eventDeleteUseCase: locator()));
}
