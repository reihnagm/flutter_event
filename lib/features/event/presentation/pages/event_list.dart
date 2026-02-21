import 'dart:collection';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import 'package:flutter_event/common/helpers/enum.dart';
import 'package:flutter_event/common/utils/color_resources.dart';
import 'package:flutter_event/common/utils/custom_themes.dart';
import 'package:flutter_event/features/profile/presentation/provider/profile_notifier.dart';
import 'package:flutter_event/features/event/data/models/event.dart';
import 'package:flutter_event/features/event/presentation/pages/event_detail.dart';
import 'package:flutter_event/features/event/presentation/pages/form_create.dart';
import 'package:flutter_event/features/event/presentation/pages/form_edit.dart';
import 'package:flutter_event/features/event/presentation/provider/event_list_notifier.dart';
import 'package:flutter_event/shared/basewidgets/button/bounce.dart';
import 'package:flutter_event/shared/basewidgets/modal/modal.dart';

class EventListPage extends StatefulWidget {
  static const String route = '/event-list';
  const EventListPage({super.key});

  @override
  State<EventListPage> createState() => EventListPageState();
}

class EventListPageState extends State<EventListPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late final EventListNotifier _eventListNotifier;
  late final ProfileNotifier _profileNotifier;

  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  static int _getHashCode(DateTime key) {
    return key.day * 1000000 + key.month * 10000 + key.year;
  }

  @override
  void initState() {
    super.initState();
    _eventListNotifier = context.read<EventListNotifier>();
    _profileNotifier = context.read<ProfileNotifier>();

    Future.microtask(_getData);
  }

  Future<void> _getData() async {
    await Future.wait([_eventListNotifier.eventList(), _profileNotifier.getProfile()]);
    if (!mounted) return;

    _eventListNotifier.updateSelectedDate(_selectedDay);
    _eventListNotifier.addSelectedEvents(_getEventsForDay(_selectedDay));
  }

  List<EventItem> _getEventsForDay(DateTime day) {
    final source = _eventListNotifier.events;

    final kEvents = LinkedHashMap<DateTime, List<EventItem>>(
      equals: isSameDay,
      hashCode: _getHashCode,
    )..addAll(source);

    return kEvents[day] ?? <EventItem>[];
  }

  void _onDaySelected(DateTime selectedDayParam, DateTime focusedDayParam) {
    if (isSameDay(_selectedDay, selectedDayParam)) return;

    setState(() {
      _selectedDay = selectedDayParam;
      _focusedDay = focusedDayParam;
    });

    _eventListNotifier.updateSelectedDate(selectedDayParam);
    _eventListNotifier.addSelectedEvents(_getEventsForDay(selectedDayParam));
  }

  @override
  Widget build(BuildContext context) {
    final kToday = DateTime.now();
    final kFirstDay = DateTime(kToday.year, kToday.month - 3, kToday.day);
    final kLastDay = DateTime(kToday.year, kToday.month + 3, kToday.day);

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: ColorResources.black,
        centerTitle: true,
        title: Text(
          "My Event",
          style: montserratRegular.copyWith(fontSize: 16.0, color: Colors.white),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(left: 16.0, right: 16.0),
            child: InkWell(
              onTap: () => _scaffoldKey.currentState?.openEndDrawer(),
              child: const Icon(Icons.menu, color: ColorResources.white),
            ),
          ),
        ],
      ),
      endDrawer: _EndDrawer(
        onCreateForm: () {
          Navigator.of(context).maybePop();
          Navigator.pushNamed(context, FormEventCreatePage.route).then((val) {
            if (val != null) _getData();
          });
        },
        onLogout: () {
          Navigator.of(context).maybePop();
          GDialog.logout();
        },
      ),
      body: Consumer<EventListNotifier>(
        builder: (context, notifier, _) {
          if (notifier.state == ProviderState.loading) {
            return const Center(child: SpinKitChasingDots(size: 16.0, color: ColorResources.black));
          }

          return RefreshIndicator.adaptive(
            onRefresh: _getData,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              slivers: [
                SliverList(
                  delegate: SliverChildListDelegate([
                    TableCalendar<EventItem>(
                      locale: 'id_ID',
                      weekNumbersVisible: false,
                      daysOfWeekVisible: false,
                      headerStyle: const HeaderStyle(
                        titleCentered: true,
                        formatButtonVisible: false,
                      ),
                      daysOfWeekHeight: 20.0,
                      calendarBuilders: CalendarBuilders(
                        todayBuilder: (context, _, __) {
                          return _DayCell(
                            text: "${DateTime.now().day}",
                            isToday: true,
                            isSelected: false,
                          );
                        },
                        defaultBuilder: (context, day, __) {
                          return Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text(
                              "${day.day}",
                              style: montserratRegular.copyWith(
                                fontSize: 13.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        },
                        selectedBuilder: (context, day, _) {
                          return _DayCell(text: "${day.day}", isToday: false, isSelected: true);
                        },
                      ),
                      firstDay: kFirstDay,
                      lastDay: kLastDay,
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                      startingDayOfWeek: StartingDayOfWeek.monday,
                      eventLoader: _getEventsForDay,
                      calendarStyle: const CalendarStyle(outsideDaysVisible: true),
                      onDaySelected: _onDaySelected,
                      onPageChanged: (val) => setState(() => _focusedDay = val),
                    ),

                    // List event untuk tanggal terpilih
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 8.0),
                      shrinkWrap: true,
                      itemCount: notifier.selectedEvents.length,
                      itemBuilder: (context, i) {
                        final event = notifier.selectedEvents[i];

                        return Bouncing(
                          onPress: () {
                            Navigator.pushNamed(
                              context,
                              EventDetailPage.route,
                              arguments: {"event": event},
                            );
                          },
                          child: _EventCard(
                            name: event.title.isNotEmpty ? event.title : "-",
                            images: event.images,
                            onEdit: () {
                              Navigator.pushNamed(
                                context,
                                FormEventEditPage.route,
                                arguments: {"id": event.id},
                              ).then((val) {
                                if (val != null) _getData();
                              });
                            },
                            onDelete: () async {
                              // await GDialog.eventDelete(id: event.id);
                              // await _getData();
                            },
                          ),
                        );
                      },
                    ),
                  ]),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _EndDrawer extends StatelessWidget {
  final VoidCallback onCreateForm;
  final VoidCallback onLogout;

  const _EndDrawer({required this.onCreateForm, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: Column(
        children: [
          const SizedBox(height: 40.0),

          Consumer<ProfileNotifier>(
            builder: (context, notifier, _) {
              final isLoading = notifier.state == ProviderState.loading;
              final fullname = isLoading ? "..." : (notifier.entity.fullname?.toString() ?? "...");
              final avatarUrl = isLoading ? null : notifier.entity.avatar?.toString();

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ProfileAvatar(avatarUrl: avatarUrl),
                  const SizedBox(height: 10.0),
                  Text(
                    fullname,
                    style: montserratRegular.copyWith(
                      fontSize: 16,
                      color: ColorResources.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 30.0),

          ListTile(
            leading: const Icon(Icons.edit),
            title: Text(
              "Create Form",
              style: montserratRegular.copyWith(color: ColorResources.black),
            ),
            onTap: onCreateForm,
          ),

          const SizedBox(height: 24.0),
          const Spacer(),

          ListTile(
            leading: const Icon(Icons.logout),
            title: Text("Logout", style: montserratRegular.copyWith(color: ColorResources.black)),
            onTap: onLogout,
          ),
          const SizedBox(height: 20.0),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  final String? avatarUrl;
  const _ProfileAvatar({required this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    const fallback = AssetImage('assets/images/default_image.png');

    if (avatarUrl == null || avatarUrl!.isEmpty) {
      return CircleAvatar(radius: 30, backgroundImage: fallback, backgroundColor: Colors.grey[200]);
    }

    return CachedNetworkImage(
      imageUrl: avatarUrl!,
      imageBuilder: (context, imageProvider) => CircleAvatar(
        radius: 30.0,
        backgroundColor: Colors.grey[200],
        backgroundImage: imageProvider,
      ),
      placeholder: (context, url) =>
          CircleAvatar(radius: 30.0, backgroundColor: Colors.grey[200], backgroundImage: fallback),
      errorWidget: (context, url, error) =>
          CircleAvatar(radius: 30.0, backgroundColor: Colors.grey[200], backgroundImage: fallback),
    );
  }
}

class _DayCell extends StatelessWidget {
  final String text;
  final bool isToday;
  final bool isSelected;

  const _DayCell({required this.text, required this.isToday, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    final BoxDecoration decoration;

    if (isToday) {
      decoration = BoxDecoration(
        color: const Color(0xff5690FF),
        border: Border.all(color: const Color(0xffFFFFFF), width: 2.0),
        borderRadius: BorderRadius.circular(8.0),
      );
    } else if (isSelected) {
      decoration = BoxDecoration(
        border: Border.all(color: const Color(0xff5690FF), width: 2.0),
        borderRadius: BorderRadius.circular(8.0),
      );
    } else {
      decoration = BoxDecoration(borderRadius: BorderRadius.circular(8.0));
    }

    return Container(
      alignment: Alignment.center,
      width: 45.0,
      height: 45.0,
      margin: const EdgeInsets.all(10.0),
      decoration: decoration,
      child: Text(
        text,
        style: montserratRegular.copyWith(
          color: isToday ? Colors.white : ColorResources.black,
          fontSize: 13.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final String name;
  final List<EventImage> images;
  final VoidCallback onEdit;
  final Future<void> Function() onDelete;

  const _EventCard({
    required this.name,
    required this.images,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 15.0, bottom: 15.0, left: 16.0, right: 16.0),
      decoration: BoxDecoration(
        color: ColorResources.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5.0,
            blurRadius: 7.0,
            offset: const Offset(0.0, 3.0),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _EventCoverCarousel(images: images),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10.0),
            margin: const EdgeInsets.only(left: 15.0, right: 15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    name,
                    overflow: TextOverflow.ellipsis,
                    style: montserratRegular.copyWith(fontWeight: FontWeight.bold, fontSize: 14.0),
                  ),
                ),
                const SizedBox(width: 12.0),
                Row(
                  children: [
                    InkWell(onTap: onEdit, child: const Icon(Icons.edit, size: 14.0)),
                    const SizedBox(width: 15.0),
                    InkWell(
                      onTap: () async => onDelete(),
                      child: const Icon(Icons.delete, color: ColorResources.error, size: 14.0),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EventCoverCarousel extends StatefulWidget {
  final List<EventImage> images;
  const _EventCoverCarousel({required this.images});

  @override
  State<_EventCoverCarousel> createState() => _EventCoverCarouselState();
}

class _EventCoverCarouselState extends State<_EventCoverCarousel> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    const fallback = AssetImage('assets/images/default_image.png');

    // 0 images => fallback
    if (widget.images.isEmpty) {
      return Container(
        height: 200.0,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12.0),
            topRight: Radius.circular(12.0),
          ),
          image: const DecorationImage(image: fallback, fit: BoxFit.fitWidth),
        ),
      );
    }

    // carousel items
    final items = widget.images.map((img) => _CarouselImage(url: img.path)).toList();

    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(12.0),
            topRight: Radius.circular(12.0),
          ),
          child: CarouselSlider(
            items: items,
            options: CarouselOptions(
              height: 200.0,
              viewportFraction: 1.0,
              enableInfiniteScroll: widget.images.length > 1,
              autoPlay: widget.images.length > 1,
              autoPlayInterval: const Duration(seconds: 4),
              onPageChanged: (i, _) => setState(() => _index = i),
            ),
          ),
        ),

        // dots indicator (kalau >1)
        if (widget.images.length > 1)
          Positioned(
            left: 0,
            right: 0,
            bottom: 8,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.images.length, (i) {
                final active = i == _index;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: active ? 10 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: active ? Colors.white : Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(99),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }
}

class _CarouselImage extends StatelessWidget {
  final String url;
  const _CarouselImage({required this.url});

  @override
  Widget build(BuildContext context) {
    const fallback = AssetImage('assets/images/default_image.png');

    if (url.trim().isEmpty) {
      return Container(
        decoration: const BoxDecoration(
          image: DecorationImage(image: fallback, fit: BoxFit.fitWidth),
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: url,
      imageBuilder: (context, imageProvider) {
        return Container(
          decoration: BoxDecoration(
            image: DecorationImage(image: imageProvider, fit: BoxFit.fitWidth),
          ),
        );
      },
      placeholder: (context, _) => Container(
        decoration: const BoxDecoration(
          image: DecorationImage(image: fallback, fit: BoxFit.fitWidth),
        ),
      ),
      errorWidget: (context, _, __) => Container(
        decoration: const BoxDecoration(
          image: DecorationImage(image: fallback, fit: BoxFit.fitWidth),
        ),
      ),
    );
  }
}
