import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:flutter_event/features/event/domain/usecases/event_delete_image.dart';

import 'package:flutter_event/common/helpers/enum.dart';

class EventDeleteImageNotifier with ChangeNotifier {
  final EventDeleteImageUseCase eventDeleteUseCase;

  EventDeleteImageNotifier({
    required this.eventDeleteUseCase
  });
  
  ProviderState _state = ProviderState.idle;
  ProviderState get state => _state;

  String _message = "";
  String get message => _message;

  void setStateProvider(ProviderState newState) {
    _state = newState;

    Future.delayed(Duration.zero, () => notifyListeners());
  }

  Future<void> eventDeleteImage({
    required String eventId,
  }) async {
    setStateProvider(ProviderState.loading);

    final result = await eventDeleteUseCase.execute(eventId: eventId);

    result.fold((l) {
      _message = l.message;
      setStateProvider(ProviderState.error);
    }, (r) {
      setStateProvider(ProviderState.loaded);
    });

  }

}