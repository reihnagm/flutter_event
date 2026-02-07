import 'package:dartz/dartz.dart';

import 'package:flutter_event/common/errors/exception.dart';
import 'package:flutter_event/common/errors/failure.dart';

import 'package:flutter_event/features/event/data/models/event.dart';
import 'package:flutter_event/features/event/data/datasources/event_remote_data_source.dart';
import 'package:flutter_event/features/event/data/models/event_detail.dart';

import 'package:flutter_event/features/event/domain/repositories/event_repository.dart';

class EventRepositoryImpl implements EventRepository {
  final EventRemoteDataSource remoteDataSource;

  EventRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, EventModel>> eventList() async {
    try {
      var result = await remoteDataSource.eventList();
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message.toString()));
    } catch (e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> eventStore({
    required String id,
    required String title,
    required String caption,
    required String captionHtml,
    required String startDate,
    required String endDate,
    required String startTime,
    required String endTime
  }) async {
    try {
      var result =  await remoteDataSource.eventStore(
        id: id,
        title: title, caption: caption, captionHtml: captionHtml,
        startDate: startDate,
        startTime: startTime, 
        endDate: endDate, endTime: endTime
      );
      return Right(result);
    } on ServerException catch(e) { 
      return Left(ServerFailure(e.message.toString()));
    } catch(e) {  
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> eventUpdate({
    required String id,
    required String title,
    required String caption,
    required String captionHtml,
    required String startDate,
    required String endDate,
    required String startTime,
    required String endTime
  }) async {
    try {
      var result =  await remoteDataSource.eventUpdate(
        id: id,
        title: title, caption: caption, 
        captionHtml: captionHtml,
        startDate: startDate,
        startTime: startTime, 
        endDate: endDate, endTime: endTime
      );
      return Right(result);
    } on ServerException catch(e) { 
      return Left(ServerFailure(e.message.toString()));
    } catch(e) {  
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> eventDelete({
    required String id
  }) async {
       try {
      var result = await remoteDataSource.eventDelete(
        id: id,
      );
      return Right(result);
    } on ServerException catch(e) { 
      return Left(ServerFailure(e.message.toString()));
    } catch(e) {  
      return Left(UnexpectedFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, void>> eventStoreImage({
    required String path, 
    required String eventId
  }) async {
    try {
      var result = await remoteDataSource.eventStoreImage(eventId: eventId, path: path);
      return Right(result);
    } on ServerException catch(e) {
      return Left(ServerFailure(e.message.toString()));
    } catch(e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, EventDetailModel>> eventDetail({required String id}) async {
    try {
      var result = await remoteDataSource.eventDetail(id: id);
      return Right(result);
    } on ServerException catch(e) {
      return Left(ServerFailure(e.message.toString()));
    } catch(e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }
  
  @override
  Future<Either<Failure, void>> eventDeleteImage({required String eventId}) async {
    try {
      var result = await remoteDataSource.eventDeleteImage(eventId: eventId);
      return Right(result);
    } on ServerException catch(e) {
      return Left(ServerFailure(e.message.toString()));
    } catch(e) {
      return Left(UnexpectedFailure(e.toString()));
    }
  }

}