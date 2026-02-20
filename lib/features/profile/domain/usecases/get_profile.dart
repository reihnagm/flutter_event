import 'package:dartz/dartz.dart';

import 'package:flutter_event/common/errors/failure.dart';
import 'package:flutter_event/features/auth/data/models/profile.dart';

import 'package:flutter_event/features/profile/domain/repositories/profile_repository.dart';

class GetProfileUseCase {
  final ProfileRepository repository;

  GetProfileUseCase(this.repository);

  Future<Either<Failure, ProfileModel>> execute() {
    return repository.getProfile();
  }
}
