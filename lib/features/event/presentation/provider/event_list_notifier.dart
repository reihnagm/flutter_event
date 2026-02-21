import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:flutter_event/common/helpers/enum.dart';
import 'package:flutter_event/features/event/data/models/event.dart';
import 'package:flutter_event/features/event/domain/usecases/event_list.dart';

class EventListNotifier with ChangeNotifier {
  final EventListUseCase eventListUseCase;

  EventListNotifier({required this.eventListUseCase});

  DateTime selectedDate = DateTime.now();

  final List<EventItem> _entity = [];
  List<EventItem> get entity => [..._entity];

  final Map<DateTime, List<EventItem>> _events = {};
  Map<DateTime, List<EventItem>> get events => {..._events};

  List<EventItem> _selectedEvents = [];
  List<EventItem> get selectedEvents => [..._selectedEvents];

  ProviderState _state = ProviderState.idle;
  ProviderState get state => _state;

  String _message = "";
  String get message => _message;

  void setStateProvider(ProviderState newState) {
    _state = newState;
    notifyListeners();
  }

  void addSelectedEvents(List<EventItem> events) {
    _selectedEvents = events;
    notifyListeners();
  }

  void updateSelectedDate(DateTime selectedDateParam) {
    selectedDate = selectedDateParam;
    notifyListeners();
  }

  DateTime _normalizeDay(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  /// start fallback:
  /// - startDate
  /// - createdAt
  /// - today
  DateTime _startFallback(EventItem e) {
    return _normalizeDay(e.startDate ?? e.createdAt ?? DateTime.now());
  }

  /// end fallback:
  /// - endDate (kalau ada)
  /// - start (biar 1 hari)
  DateTime _endFallback(EventItem e, DateTime normalizedStart) {
    final rawEnd = e.endDate;
    if (rawEnd == null) return normalizedStart;
    return _normalizeDay(rawEnd);
  }

  /// Expand event ke semua hari dalam range (inclusive)
  Iterable<DateTime> _daysInRange(DateTime start, DateTime end) sync* {
    // safety kalau data kotor (end < start)
    if (end.isBefore(start)) {
      final tmp = start;
      start = end;
      end = tmp;
    }

    var cur = start;
    while (!cur.isAfter(end)) {
      yield cur;
      cur = cur.add(const Duration(days: 1));
    }
  }

  Map<DateTime, List<EventItem>> _groupByDateRange(List<EventItem> items) {
    final Map<DateTime, List<EventItem>> out = {};

    for (final e in items) {
      final start = _startFallback(e);
      final end = _endFallback(e, start);

      for (final day in _daysInRange(start, end)) {
        (out[day] ??= <EventItem>[]).add(e);
      }
    }

    return out;
  }

  Future<void> eventList() async {
    setStateProvider(ProviderState.loading);

    final result = await eventListUseCase.execute();

    result.fold(
      (failure) {
        _message = failure.message;
        setStateProvider(ProviderState.error);
      },
      (success) {
        final List<EventItem> items = success.data.events;

        _entity
          ..clear()
          ..addAll(items);

        _events
          ..clear()
          ..addAll(_groupByDateRange(items));

        // set selected events = hari ini (kalau ada)
        _selectedEvents = [];
        final todayStr = DateFormat('dd/MM/yyyy').format(DateTime.now());

        for (final entry in _events.entries) {
          if (DateFormat('dd/MM/yyyy').format(entry.key) == todayStr) {
            _selectedEvents = entry.value;
            break;
          }
        }

        setStateProvider(ProviderState.loaded);
      },
    );
  }
}
