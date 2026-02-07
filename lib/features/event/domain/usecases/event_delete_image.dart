
import 'package:dartz/dartz.dart';

import 'package:flutter_event/common/errors/failure.dart';

import 'package:flutter_event/features/event/domain/repositories/event_repository.dart';

class EventDeleteImageUseCase {
  final EventRepository repository;

  EventDeleteImageUseCase(this.repository);

  Future<Either<Failure, void>> execute({
    required String eventId,
  }) {
    return repository.eventDeleteImage(
      eventId: eventId,
    );
  }
}