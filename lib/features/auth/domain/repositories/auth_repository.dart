import 'package:dartz/dartz.dart';

import 'package:flutter_event/common/errors/failure.dart';

import 'package:flutter_event/features/auth/data/models/auth.dart';
import 'package:flutter_event/features/auth/data/models/profile.dart';

abstract class AuthRepository {
   Future<Either<Failure, AuthModel>> login({
    required String email, 
    required String password
  });
  Future<Either<Failure, AuthModel>> register({
    required String fullname,
    required String email,
    required String password
  });
  Future<Either<Failure, ProfileModel>> getProfile();
}