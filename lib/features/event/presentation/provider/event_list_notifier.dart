import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:flutter_event/common/helpers/enum.dart';
import 'package:flutter_event/features/event/data/models/event.dart';
import 'package:flutter_event/features/event/domain/usecases/event_list.dart';

class EventListNotifier with ChangeNotifier {
  final EventListUseCase eventListUseCase;

  EventListNotifier({required this.eventListUseCase});

  DateTime selectedDate = DateTime.now();

  final List<EventData> _entity = [];
  List<EventData> get entity => [..._entity];

  final List<DateRangeModel> _data = [];
  List<DateRangeModel> get data => [..._data];

  final Map<DateTime, List<Map<String, dynamic>>> _events = {};
  Map<DateTime, List<Map<String, dynamic>>> get events => {..._events};

  List<Map<String, dynamic>> _selectedEvents = [];
  List<Map<String, dynamic>> get selectedEvents => [..._selectedEvents];

  ProviderState _state = ProviderState.idle;
  ProviderState get state => _state;

  String _message = "";
  String get message => _message;

  void setStateProvider(ProviderState newState) {
    _state = newState;
    notifyListeners();
  }

  void addSelectedEvents(List<Map<String, dynamic>> events) {
    _selectedEvents = events;
    notifyListeners();
  }

  void updateSelectedDate(DateTime selectedDateParam) {
    selectedDate = selectedDateParam;
    notifyListeners();
  }

  Future<void> eventList() async {
    setStateProvider(ProviderState.loading);

    final result = await eventListUseCase.execute();

    result.fold((failure) {
      _message = failure.message;
      setStateProvider(ProviderState.error);
    }, (success) {
      // Clear previous data
      _entity.clear();
      _selectedEvents.clear();
      _data.clear();
      _events.clear();

      // Populate new data
      _entity.addAll(success.data);

      for (EventData el in _entity) {
        _data.add(DateRangeModel(
          startDate: DateTime(el.startDate.year, el.startDate.month, el.startDate.day),
          endDate: DateTime(el.endDate.year, el.endDate.month, el.endDate.day),
          dataArray: [
            {
              "id": el.id,
              "name": el.title,
              "caption": el.caption,
              "medias": el.media,
              "createdAt": el.createdAt,
            }
          ],
        ));
      }

      final Map<DateTime, List<Map<String, dynamic>>> groupedData = groupDataByDate(_data);
      _events.addAll(groupedData);

      // Set selected events to today if available
      final todayStr = DateFormat('dd/MM/yyyy').format(DateTime.now());
      for (var entry in groupedData.entries) {
        if (DateFormat('dd/MM/yyyy').format(entry.key) == todayStr) {
          _selectedEvents = entry.value;
          break;
        }
      }

      setStateProvider(ProviderState.loaded);
    });
  }
}
