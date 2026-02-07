import 'package:dio/dio.dart';

import 'dart:developer' as dev;

import 'package:flutter_event/common/constants/remote_data_source_consts.dart';
import 'package:flutter_event/common/errors/exception.dart';

import 'package:flutter_event/features/auth/data/models/auth.dart';
import 'package:flutter_event/features/auth/data/models/profile.dart';

abstract class AuthRemoteDataSource {
  Future<AuthModel> login({
    required String email,
    required String password,
  });
  Future<AuthModel> register({
    required String fullname,
    required String email, 
    required String password
  });
  Future<ProfileModel> getProfile();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {

  Dio client;

  AuthRemoteDataSourceImpl({required this.client});

  @override
  Future<AuthModel> login({
    required String email, 
    required String password
  }) async {
    try { 
      final response = await client.post("${RemoteDataSourceConsts.baseUrl}/api/v1/login",
        data: {
          "val": email, 
          "password": password
        }
      );
      Map<String, dynamic> data = response.data;
      AuthModel authModel = AuthModel.fromJson(data);
      return authModel;
    } on DioException catch (e) {
      String message = handleDioException(e);
      throw ServerException(message);
    } catch (e, stacktrace) {
      dev.log(stacktrace.toString());
      throw Exception(e.toString());
    }
  }

  @override
  Future<AuthModel> register({
    required String fullname, 
    required String email, 
    required String password
  }) async {
    try {
      final response = await client.post("${RemoteDataSourceConsts.baseUrl}/register",
        data: {
          "fullname": fullname,
          "email": email, 
          "password": password
        }
      );
      Map<String, dynamic> data = response.data;
      AuthModel authModel = AuthModel.fromJson(data);
      return authModel;
    } on DioException catch (e) {
      String message = handleDioException(e);
      throw ServerException(message);
    } catch (e, stacktrace) {
      dev.log(stacktrace.toString());
      throw Exception(e.toString());
    }
  }

  @override 
  Future<ProfileModel> getProfile() async {
    try {
      final response = await client.get("${RemoteDataSourceConsts.baseUrl}/api/v1/profile");
      Map<String, dynamic> data = response.data;
      ProfileModel profileModel = ProfileModel.fromJson(data);
      return profileModel;
    } on DioException catch (e) {
      String message = handleDioException(e);
      throw ServerException(message);
    } catch (e, stacktrace) {
      dev.log(stacktrace.toString());
      throw Exception(e.toString());
    }
  }


}