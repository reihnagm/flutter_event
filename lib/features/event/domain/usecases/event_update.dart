import 'package:dartz/dartz.dart';

import 'package:flutter_event/common/errors/failure.dart';

import 'package:flutter_event/features/event/domain/repositories/event_repository.dart';

class EventUpdateUseCase {
  final EventRepository repository;

  EventUpdateUseCase(this.repository);

  Future<Either<Failure, void>> execute({
    required String id,
    required String title,
    required String content,
    required String contentHtml,
    required String startDate,
    required String endDate,
    required String startTime,
    required String endTime,
    String? locationName,
    double? latitude,
    double? longitude,
    String? mapsUrl,
    List<String>? images,
  }) {
    return repository.eventUpdate(
      id: id,
      title: title,
      content: content,
      contentHtml: contentHtml,
      startDate: startDate,
      endDate: endDate,
      startTime: startTime,
      endTime: endTime,
      locationName: locationName,
      latitude: latitude,
      longitude: longitude,
      mapsUrl: mapsUrl,
      images: images,
    );
  }
}
