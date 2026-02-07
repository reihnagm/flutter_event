
import 'package:dartz/dartz.dart';

import 'package:flutter_event/common/errors/failure.dart';

import 'package:flutter_event/features/event/data/models/event.dart';
import 'package:flutter_event/features/event/domain/repositories/event_repository.dart';

class EventListUseCase {
  final EventRepository repository;

  EventListUseCase(this.repository);

  Future<Either<Failure, EventModel>> execute() {
    return repository.eventList();
  }
}