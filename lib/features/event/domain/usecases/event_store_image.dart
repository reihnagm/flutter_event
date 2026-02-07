
import 'package:dartz/dartz.dart';

import 'package:flutter_event/common/errors/failure.dart';

import 'package:flutter_event/features/event/domain/repositories/event_repository.dart';

class EventStoreImageUseCase {
  final EventRepository repository;

  EventStoreImageUseCase(this.repository);

  Future<Either<Failure, void>> execute({
    required String path, 
    required String eventId,
  }) {
    return repository.eventStoreImage(
      path: path,
      eventId: eventId,
    );
  }
}