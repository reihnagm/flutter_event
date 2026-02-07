
import 'package:dartz/dartz.dart';

import 'package:flutter_event/common/errors/failure.dart';
import 'package:flutter_event/features/auth/data/models/auth.dart';
import 'package:flutter_event/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<Either<Failure, AuthModel>> execute({
    required String email,
    required String password,
  }) {
    return repository.login(email: email, password: password);
  }
}