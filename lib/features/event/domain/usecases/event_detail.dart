import 'package:dartz/dartz.dart';

import 'package:flutter_event/common/errors/failure.dart';

import 'package:flutter_event/features/event/data/models/event_detail.dart';
import 'package:flutter_event/features/event/domain/repositories/event_repository.dart';

class EventDetailUseCase {
  final EventRepository repository;

  EventDetailUseCase(this.repository);

  Future<Either<Failure, EventDetailResponse>> execute({required String id}) {
    return repository.eventDetail(id: id);
  }
}
