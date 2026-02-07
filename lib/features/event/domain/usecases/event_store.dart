
import 'package:dartz/dartz.dart';

import 'package:flutter_event/common/errors/failure.dart';

import 'package:flutter_event/features/event/domain/repositories/event_repository.dart';

class EventStoreUseCase {
  final EventRepository repository;

  EventStoreUseCase(this.repository);

  Future<Either<Failure, void>> execute({
    required String id,
    required String title, 
    required String caption,
    required String captionHtml,
    required String startDate,
    required String endDate,
    required String startTime,
    required String endTime
  }) {
    return repository.eventStore(
      id: id,
      title: title, 
      caption: caption,
      captionHtml: captionHtml,
      startDate: startDate,
      endDate: endDate,
      startTime: startTime,
      endTime: endTime,
    );
  }
}