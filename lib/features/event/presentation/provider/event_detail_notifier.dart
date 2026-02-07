import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:flutter_event/features/event/data/models/event_detail.dart';
import 'package:flutter_event/features/event/domain/usecases/event_detail.dart';

import 'package:flutter_event/common/helpers/enum.dart';

class EventDetailNotifier with ChangeNotifier {
  final EventDetailUseCase eventDetailUseCase;

  EventDetailNotifier({
    required this.eventDetailUseCase
  });
  
  DateTime selectedDate = DateTime.now();

  EventDetailData _entity = EventDetailData();
  EventDetailData get entity => _entity;

  ProviderState _state = ProviderState.idle;
  ProviderState get state => _state;

  String _message = "";
  String get message => _message;

  void setStateProvider(ProviderState newState) {
    _state = newState;

    Future.delayed(Duration.zero, () => notifyListeners());
  }

  Future<void> eventDetail({required String id}) async {
    setStateProvider(ProviderState.loading);

    final result = await eventDetailUseCase.execute(id: id);

    result.fold((l) {
      _message = l.message;
      setStateProvider(ProviderState.error);
    }, (r) {
      _entity = r.data;
      setStateProvider(ProviderState.loaded);
    });

  }

}