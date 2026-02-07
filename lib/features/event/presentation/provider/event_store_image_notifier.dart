import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:flutter_event/features/event/domain/usecases/event_store_image.dart';

import 'package:flutter_event/common/helpers/enum.dart';

class EventStoreImageNotifier with ChangeNotifier {
  final EventStoreImageUseCase eventStoreUseCase;

  EventStoreImageNotifier({
    required this.eventStoreUseCase
  });
  
  ProviderState _state = ProviderState.idle;
  ProviderState get state => _state;

  String _message = "";
  String get message => _message;

  void setStateProvider(ProviderState newState) {
    _state = newState;

    Future.delayed(Duration.zero, () => notifyListeners());
  }

  Future<void> eventStoreImage({
    required String eventId,
    required String path,
  }) async {
    setStateProvider(ProviderState.loading);

    final result = await eventStoreUseCase.execute(eventId: eventId, path: path);

    result.fold((l) {
      _message = l.message;
      setStateProvider(ProviderState.error);
    }, (r) {
      setStateProvider(ProviderState.loaded);
    });

  }

}