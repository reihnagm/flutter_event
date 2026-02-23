import 'package:flutter/material.dart';

import 'package:flutter_event/common/helpers/enum.dart';
import 'package:flutter_event/features/event/data/models/event_detail.dart';
import 'package:flutter_event/features/event/domain/usecases/event_detail.dart';

class EventDetailNotifier with ChangeNotifier {
  final EventDetailUseCase eventDetailUseCase;

  EventDetailNotifier({required this.eventDetailUseCase});

  EventDetail? _entity;
  EventDetail? get entity => _entity;

  ProviderState _state = ProviderState.idle;
  ProviderState get state => _state;

  String _message = "";
  String get message => _message;

  void setStateProvider(ProviderState newState) {
    _state = newState;
    notifyListeners();
  }

  Future<void> eventDetail({required String id}) async {
    setStateProvider(ProviderState.loading);

    final result = await eventDetailUseCase.execute(id: id);

    result.fold(
      (failure) {
        _message = failure.message;
        _entity = null;
        setStateProvider(ProviderState.error);
      },
      (success) {
        _entity = success.data;
        _message = "";
        setStateProvider(ProviderState.loaded);
      },
    );
  }

  void clear() {
    _entity = null;
    _message = "";
    setStateProvider(ProviderState.idle);
  }
}
