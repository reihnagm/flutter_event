import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:flutter_event/common/helpers/enum.dart';

import 'package:flutter_event/features/event/domain/usecases/event_store.dart';

class EventStoreNotifier with ChangeNotifier {
  final EventStoreUseCase eventStoreUseCase;

  EventStoreNotifier({required this.eventStoreUseCase});

  ProviderState _state = ProviderState.idle;
  ProviderState get state => _state;

  String _message = "";
  String get message => _message;

  void setStateProvider(ProviderState newState) {
    _state = newState;

    Future.delayed(Duration.zero, () => notifyListeners());
  }

  Future<void> eventStore({
    required String id,
    required String title,
    required String content,
    required String contentHtml,
    required String startDate,
    required String startTime,
    required String endDate,
    required String endTime,
    String? locationName,
    double? latitude,
    double? longitude,
    String? mapsUrl,
    List<String>? images,
  }) async {
    setStateProvider(ProviderState.loading);

    final result = await eventStoreUseCase.execute(
      id: id,
      title: title,
      content: content,
      contentHtml: contentHtml,
      startDate: startDate,
      startTime: startTime,
      endDate: endDate,
      endTime: endTime,
      locationName: locationName,
      latitude: latitude,
      longitude: longitude,
      mapsUrl: mapsUrl,
      images: images,
    );

    result.fold(
      (l) {
        _message = l.message;
        setStateProvider(ProviderState.error);
      },
      (r) {
        setStateProvider(ProviderState.loaded);
      },
    );
  }
}
