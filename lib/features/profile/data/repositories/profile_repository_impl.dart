import 'package:dartz/dartz.dart';

import 'package:flutter_event/common/errors/exception.dart';
import 'package:flutter_event/common/errors/failure.dart';

import 'package:flutter_event/features/auth/data/models/profile.dart';
import 'package:flutter_event/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:flutter_event/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, ProfileModel>> getProfile() async {
    try {
      var result = await remoteDataSource.getProfile();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message.toString()));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateProfile({required String fullname}) async {
    try {
      var result = await remoteDataSource.updateProfile(fullname: fullname);
      return Right(result);
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
}
