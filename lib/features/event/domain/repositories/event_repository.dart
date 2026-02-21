import 'package:dartz/dartz.dart';

import 'package:flutter_event/common/errors/failure.dart';

import 'package:flutter_event/features/event/data/models/event.dart';
import 'package:flutter_event/features/event/data/models/event_detail.dart';

abstract class EventRepository {
  Future<Either<Failure, EventResponse>> eventList();
  Future<Either<Failure, EventDetailResponse>> eventDetail({required String id});
  Future<Either<Failure, void>> eventStore({
    required String id,
    required String title,
    required String caption,
    required String captionHtml,
    required String startDate,
    required String endDate,
    required String startTime,
    required String endTime
  });
  Future<Either<Failure, void>> eventUpdate({
    required String id,
    required String title,
    required String caption,
    required String captionHtml,
    required String startDate,
    required String endDate,
    required String startTime,
    required String endTime
  });
  Future<Either<Failure, void>> eventDelete({
    required String id
  });
  Future<Either<Failure, void>> eventStoreImage({
    required String path,
    required String eventId
  });
  Future<Either<Failure, void>> eventDeleteImage({
    required String eventId
  });
}