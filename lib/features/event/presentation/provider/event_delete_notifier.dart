import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:flutter_event/features/event/domain/usecases/event_delete.dart';

import 'package:flutter_event/common/helpers/enum.dart';

class EventDeleteNotifier with ChangeNotifier {
  final EventDeleteUseCase eventDeleteUseCase;

  EventDeleteNotifier({
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

  Future<void> eventDelete({required String id}) async {
    setStateProvider(ProviderState.loading);

    final result = await eventDeleteUseCase.execute(id: id);

    result.fold((l) {
      _message = l.message;
      setStateProvider(ProviderState.error);
    }, (r) {
      setStateProvider(ProviderState.loaded);
    });

  }

}