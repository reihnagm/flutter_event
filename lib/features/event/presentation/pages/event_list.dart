import 'dart:collection';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_event/features/auth/presentation/provider/profile_notifier.dart';
import 'package:flutter_event/features/event/presentation/pages/event_detail.dart';
import 'package:flutter_event/shared/basewidgets/modal/modal.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

import 'package:flutter_event/shared/basewidgets/button/bounce.dart';

import 'package:table_calendar/table_calendar.dart';

import 'package:flutter_event/common/helpers/enum.dart';
import 'package:flutter_event/common/utils/color_resources.dart';
import 'package:flutter_event/common/utils/custom_themes.dart';

import 'package:flutter_event/features/event/presentation/pages/form_create.dart';
import 'package:flutter_event/features/event/presentation/pages/form_edit.dart';
import 'package:flutter_event/features/event/presentation/provider/event_list_notifier.dart';

class EventListPage extends StatefulWidget {
  static const String route = '/event-list';

  const EventListPage({super.key});

  @override
  State<EventListPage> createState() => EventListPageState();
}

class EventListPageState extends State<EventListPage> {

  GlobalKey<ScaffoldState> globalKey = GlobalKey<ScaffoldState>();
  
  late EventListNotifier eventListNotifier; 
  late ProfileNotifier profileNotifier;

  DateTime focusedDay = DateTime.now();
  DateTime selectedDay = DateTime.now();

  static int getHashCode(DateTime key) {
    return key.day * 1000000 + key.month * 10000 + key.year;
  }

  List<Map<String, dynamic>> getEventsForDay(DateTime day) {   
    final kEvents = LinkedHashMap<DateTime, List<Map<String, dynamic>>>(
      equals: isSameDay,
      hashCode: getHashCode,
    )..addAll(eventListNotifier.events);
  
    return kEvents[day] ?? [];
  }

  void onDaySelected(DateTime selectedDayParam, DateTime focusedDayParam) {
    if (!isSameDay(selectedDay, selectedDayParam)) {
      setState(() {
        selectedDay = selectedDayParam;
        focusedDay = focusedDayParam;
      });

      eventListNotifier.updateSelectedDate(selectedDayParam);
      eventListNotifier.addSelectedEvents(getEventsForDay(selectedDayParam));
    }
  }
  
  Future<void> getData() async {
    if (!mounted) return;
    
    await Future.wait([
      eventListNotifier.eventList(),
      profileNotifier.getProfile()
    ]);

    eventListNotifier.updateSelectedDate(selectedDay);
    eventListNotifier.addSelectedEvents(getEventsForDay(selectedDay));
  }

  @override 
  void initState() {
    super.initState();

    eventListNotifier = context.read<EventListNotifier>();
    profileNotifier = context.read<ProfileNotifier>();

    Future.microtask(() => getData());
  }

  @override 
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    DateTime kToday = DateTime.now();
    DateTime kFirstDay = DateTime(kToday.year, kToday.month - 3, kToday.day);
    DateTime kLastDay = DateTime(kToday.year, kToday.month + 3, kToday.day);

    return Scaffold(
      key: globalKey,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: ColorResources.black,
        centerTitle: true,
        title: Text("My Event",
          style: montserratRegular.copyWith(
            fontSize: 16.0,
            color: Colors.white
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(
              left: 16.0,
              right: 16.0
            ),
            child: InkWell(
              onTap: () {
                globalKey.currentState?.openEndDrawer();
              },
              child: const Icon(
                Icons.menu,
                color: ColorResources.white,
              ),
            ),
          )
        ],
      ),
      endDrawer: Drawer(
        backgroundColor: Colors.white,
        child: Column(
          children: [
           
            const SizedBox(height: 40.0),
            
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                context.watch<ProfileNotifier>().state == ProviderState.loading 
                ? CircleAvatar(
                    radius: 30,
                    backgroundImage: const AssetImage('assets/images/default_image.png'),
                    backgroundColor: Colors.grey[200],
                  )
                : CachedNetworkImage(
                    imageUrl: profileNotifier.entity.avatar.toString(),
                    imageBuilder: (BuildContext context, ImageProvider<Object> imageProvider) {
                      return CircleAvatar(
                        radius: 30.0,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: imageProvider,
                      );
                    },
                    errorWidget: (BuildContext context, String url, dynamic error) {
                      return CircleAvatar(
                        radius: 30.0,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: const AssetImage('assets/images/default_image.png'),
                      );
                    },
                    placeholder: (BuildContext context, String url) {
                      return CircleAvatar(
                        radius: 30.0,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: const AssetImage('assets/images/default_image.png'),
                      ); 
                    },
                  ),

                const SizedBox(height: 10.0),

                Text(context.watch<ProfileNotifier>().state == ProviderState.loading 
                ? "..." 
                : profileNotifier.entity.fullname.toString(),
                  style: montserratRegular.copyWith(
                    fontSize: 16,
                    color: ColorResources.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),

              ],
            ),

            const SizedBox(height: 30.0),

            // Create Form
            ListTile(
              leading: const Icon(Icons.edit),
              title: Text(
                "Create Form",
                style: montserratRegular.copyWith(
                  color: ColorResources.black,
                ),
              ),
              onTap: () {
                Navigator.of(context).maybePop();
                Navigator.pushNamed(context, FormEventCreatePage.route).then((val) {
                  if (val != null) {
                    getData();
                  }
                });
              },
            ),

            const SizedBox(height: 24.0),
            const Spacer(),

            // Logout
            ListTile(
              leading: const Icon(Icons.logout),
              title: Text(
                "Logout",
                style: montserratRegular.copyWith(
                  color: ColorResources.black,
                ),
              ),
              onTap: () {
                Navigator.of(context).maybePop();
                GDialog.logout();
              },
            ),
            const SizedBox(height: 20.0),
          ],
        ),
      ),



      body: context.watch<EventListNotifier>().state == ProviderState.loading 
      ? const Center(
          child: SpinKitChasingDots(
            size: 16.0,
            color: ColorResources.black,
          )
        ) 
      : RefreshIndicator.adaptive(
          onRefresh: () {
            return Future.sync(() {
              getData();
            });
          },
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            slivers: [

              SliverList(
                delegate: SliverChildListDelegate([
                  
                  TableCalendar(
                    locale: 'id_ID',
                    weekNumbersVisible: false,
                    daysOfWeekVisible: false,
                    headerStyle: const HeaderStyle(
                      titleCentered: true,
                      formatButtonVisible: false,
                    ),
                    daysOfWeekHeight: 20.0,
                      calendarBuilders: CalendarBuilders(
                        todayBuilder: (BuildContext context, _, __) {
                          return Container(
                            alignment: Alignment.center,
                            width: 45.0,
                            height: 45.0,
                            margin: const EdgeInsets.all(10.0),
                            decoration: BoxDecoration(
                              color: const Color(0xff5690FF),
                              border: Border.all(
                                color: const Color(0xffFFFFFF),
                                width: 2.0
                              ),
                              borderRadius: BorderRadius.circular(8.0)
                            ),
                            child: Text("${DateTime.now().day}",
                              style: montserratRegular.copyWith(
                                color: Colors.white,
                                fontSize: 13.0,
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          );
                        },
                        defaultBuilder: (BuildContext context, DateTime day, __) {
                          return Container(
                            margin: const EdgeInsets.all(10.0),
                            padding: EdgeInsets.zero,
                            child: Text("${day.day}",
                              style: montserratRegular.copyWith(
                                fontSize: 13.0,
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          );
                        },
                        selectedBuilder: (_, __, DateTime focusedDay) {
                          return Container(
                            alignment: Alignment.center,
                            width: 45.0,
                            height: 45.0,
                            margin: const EdgeInsets.all(10.0),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xff5690FF),
                                width: 2.0
                              ),
                              borderRadius: BorderRadius.circular(8.0)
                            ),
                            child: Text("${focusedDay.day}",
                              style: montserratRegular.copyWith(
                                fontSize: 13.0,
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          );
                        },
                      ),
                    firstDay: kFirstDay,
                    lastDay: kLastDay,
                    focusedDay: focusedDay,
                    selectedDayPredicate: (DateTime day) => isSameDay(selectedDay, day),
                    startingDayOfWeek: StartingDayOfWeek.monday,
                    eventLoader: getEventsForDay,
                    calendarStyle: const CalendarStyle(
                      outsideDaysVisible: true,
                    ),
                    onDaySelected: onDaySelected,
                    onPageChanged: (DateTime val) {
                      focusedDay = val;
                    },
                  ),
              
                  Consumer<EventListNotifier>(
                    builder: (BuildContext context, EventListNotifier notifier, Widget? child) {
                      return ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                          vertical: 30.0,  
                          horizontal: 8.0
                        ),
                        shrinkWrap: true,
                        itemCount: notifier.selectedEvents.length,
                        itemBuilder: (BuildContext context, int i) {
                        List<dynamic> medias = notifier.selectedEvents[i]["medias"];

                        return Bouncing(
                          onPress: () {
                            Navigator.pushNamed(context, 
                              EventDetailPage.route,
                              arguments: {
                                "event": notifier.selectedEvents[i]
                              }
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(
                              top: 15.0,
                              bottom: 15.0,
                              left: 16.0,
                              right: 16.0,
                            ),
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
                              ]
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [

                                medias.isEmpty 
                                ? Container(
                                    height: 200.0,
                                    decoration: const BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(12.0),
                                        topRight: Radius.circular(12.0)
                                      ),
                                      image: DecorationImage(
                                        image: AssetImage('assets/images/default_image.png'),
                                        fit: BoxFit.fitWidth
                                      )
                                    ),
                                  ) 
                                : CachedNetworkImage(
                                    imageUrl: medias.first["path"],
                                    imageBuilder: (BuildContext context, ImageProvider<Object> imageProvider) {
                                      return Container(
                                        height: 200.0,
                                        decoration: BoxDecoration(
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(12.0),
                                            topRight: Radius.circular(12.0)
                                          ),
                                          image: DecorationImage(
                                            image: imageProvider,
                                            fit: BoxFit.fitWidth
                                          )
                                        ),
                                      );
                                    },
                                    errorWidget: (BuildContext context, String val, _) {
                                      return Container(
                                        height: 200.0,
                                        decoration: const BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(12.0),
                                            topRight: Radius.circular(12.0)
                                          ),
                                          image: DecorationImage(
                                            image: AssetImage('assets/images/default_image.png'),
                                            fit: BoxFit.fitWidth
                                          )
                                        ),
                                      );
                                    },
                                    placeholder: (BuildContext context, String val) {
                                      return Container(
                                        height: 200.0,
                                        decoration: const BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(12.0),
                                            topRight: Radius.circular(12.0)
                                          ),
                                          image: DecorationImage(
                                            image: AssetImage('assets/images/default_image.png'),
                                            fit: BoxFit.fitWidth
                                          )
                                        ),
                                      );
                                    },
                                  ),
              
                                Container(
                                  width: 350.0,
                                  padding:const  EdgeInsets.all(10.0),
                                  margin: const EdgeInsets.only(
                                    left: 15.0,
                                    right: 15.0
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                        
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
              
                                            Row(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                  
                                                Text(notifier.selectedEvents[i]["name"].toString(),
                                                  overflow: TextOverflow.ellipsis,
                                                  style: montserratRegular.copyWith(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14.0
                                                  ),
                                                ),
                                                
                                                Row(
                                                  mainAxisSize: MainAxisSize.max,
                                                  children: [
              
                                                    InkWell(
                                                      onTap: () {
                                                        Navigator.pushNamed(context, FormEventEditPage.route, 
                                                          arguments: {
                                                            "id": notifier.selectedEvents[i]["id"]
                                                          }
                                                        ).then((val) {
                                                          if(val != null) {
                                                            getData();
                                                          }
                                                        });
                                                      },
                                                      child: const Icon(
                                                        Icons.edit,
                                                        size: 14.0,
                                                      ),
                                                    ),
              
                                                    const SizedBox(width: 15.0),
              
                                                    InkWell(
                                                      onTap: () async {
                                                        await GDialog.eventDelete(id: notifier.selectedEvents[i]["id"]);
                                                      },
                                                      child: const Icon(
                                                        Icons.delete,
                                                        color: ColorResources.error,
                                                        size: 14.0,
                                                      ),
                                                    ),
              
              
                                                  ],
                                                ),
                                                
                                              ],
                                            ), 
                                        
                                          ],
                                        ),
                                      ),
                        
                                    ],
                                  ),
                                )
                              ],
                            )
                          ),
                        );
                      });
                    },
                
                  )
              
                ])
              )
          ],
        ),
      )
    );
  }
}