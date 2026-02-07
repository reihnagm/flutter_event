
import 'package:dartz/dartz.dart';

import 'package:flutter_event/common/errors/failure.dart';

import 'package:flutter_event/features/event/domain/repositories/event_repository.dart';

class EventDeleteUseCase {
  final EventRepository repository;

  EventDeleteUseCase(this.repository);

  Future<Either<Failure, void>> execute({
    required String id
  }) {
    return repository.eventDelete(
      id: id
    );
  }
}