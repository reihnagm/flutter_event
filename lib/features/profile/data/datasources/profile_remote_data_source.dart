import 'package:dio/dio.dart';

import 'dart:developer';

import 'package:flutter_event/common/constants/remote_data_source_consts.dart';
import 'package:flutter_event/common/errors/exception.dart';
import 'package:flutter_event/common/helpers/dio.dart';

import 'package:flutter_event/features/auth/data/models/profile.dart';
import 'package:flutter_event/features/event/data/models/event_detail.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileModel> getProfile();
  Future<void> updateProfile({required String fullname});
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  ProfileRemoteDataSourceImpl();

  @override
  Future<ProfileModel> getProfile() async {
    try {
      final dio = DioHelper.shared.getClient();
      final response = await dio.get("${RemoteDataSourceConsts.baseUrl}/api/v1/profile/me");
      Map<String, dynamic> data = response.data;
      ProfileModel profileModel = ProfileModel.fromJson(data);
      return profileModel;
    } on DioException catch (e) {
      String message = handleDioException(e);
      log(message);
      throw ServerException(message);
    } catch (e, stacktrace) {
      log(stacktrace.toString());
      throw Exception(e.toString());
    }
  }

  @override
  Future<void> updateProfile({required String fullname}) async {
    try {
      final dio = DioHelper.shared.getClient();
      await dio.put(
        "${RemoteDataSourceConsts.baseUrl}/api/v1/profile/me",
        data: {"fullname": fullname},
      );
    } on DioException catch (e) {
      String message = handleDioException(e);
      log(message);
      throw ServerException(message);
    } catch (e, stacktrace) {
      log(stacktrace.toString());
      throw Exception(e.toString());
    }
  }
}
