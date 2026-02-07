
import 'package:dartz/dartz.dart';

import 'package:flutter_event/common/errors/failure.dart';

import 'package:flutter_event/features/auth/data/models/profile.dart';
import 'package:flutter_event/features/auth/domain/repositories/auth_repository.dart';

class ProfileUseCase {
  final AuthRepository repository;

  ProfileUseCase(this.repository);

  Future<Either<Failure, ProfileModel>> execute() {
    return repository.getProfile();
  }
}