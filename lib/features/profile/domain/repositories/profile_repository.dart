import 'package:dartz/dartz.dart';

import 'package:flutter_event/common/errors/failure.dart';
import 'package:flutter_event/features/auth/data/models/profile.dart';

abstract class ProfileRepository {
  Future<Either<Failure, ProfileModel>> getProfile();
  Future<Either<Failure, void>> updateProfile({required String fullname});
}
