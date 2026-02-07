import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:flutter_event/common/helpers/enum.dart';

import 'package:flutter_event/features/event/domain/usecases/event_update.dart';

class EventUpdateNotifier with ChangeNotifier {
  final EventUpdateUseCase eventUpdateUseCase;

  EventUpdateNotifier({
    required this.eventUpdateUseCase
  });
  
  ProviderState _state = ProviderState.idle;
  ProviderState get state => _state;

  String _message = "";
  String get message => _message;

  void setStateProvider(ProviderState newState) {
    _state = newState;

    Future.delayed(Duration.zero, () => notifyListeners());
  }

  Future<void> eventUpdate({
    required String id, 
    required String title,
    required String caption,
    required String captionHtml,
    required String startDate,
    required String startTime,
    required String endDate,
    required String endTime
  }) async {
    setStateProvider(ProviderState.loading);

    final result = await eventUpdateUseCase.execute(
      id: id,
      title: title, 
      caption: caption,
      captionHtml: captionHtml,
      startDate: startDate,
      startTime: startTime,
      endDate: endDate,
      endTime: endTime, 
    );

    result.fold((l) {
      _message = l.message;
      setStateProvider(ProviderState.error);
    }, (r) {
      setStateProvider(ProviderState.loaded);
    });

  }

}