import 'dart:convert';

import 'package:flutter_event/features/event/data/models/event.dart';
import 'package:intl/intl.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_event/common/utils/color_resources.dart';

import 'package:flutter_event/common/utils/custom_themes.dart';
import 'package:flutter_quill/flutter_quill.dart';

class EventDetailPage extends StatefulWidget {
  static const String route = '/event-detail';

  final EventItem event;

  const EventDetailPage({required this.event, super.key});

  @override
  State<EventDetailPage> createState() => EventDetailPageState();
}

class EventDetailPageState extends State<EventDetailPage> {
  QuillController qcC = QuillController.basic();

  late ScrollController sc;

  bool isTitleVisible = true;

  void sl() {
    if (sc.offset >= 155 && isTitleVisible) {
      setState(() {
        isTitleVisible = false;
      });
    } else if (sc.offset <= 155 && !isTitleVisible) {
      setState(() {
        isTitleVisible = true;
      });
    }
  }

  @override
  void initState() {
    sc = ScrollController();
    sc.addListener(sl);

    final raw = widget.event.content.trim();
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        qcC = QuillController(
          document: Document.fromJson(List<Map<String, dynamic>>.from(decoded)),
          selection: const TextSelection.collapsed(offset: 0),
          readOnly: true,
        );
      } else if (decoded is Map && decoded['ops'] is List) {
        qcC = QuillController(
          document: Document.fromJson(List<Map<String, dynamic>>.from(decoded['ops'])),
          selection: const TextSelection.collapsed(offset: 0),
          readOnly: true,
        );
      } else {
        qcC = QuillController(
          document: Document()..insert(0, '$raw\n'),
          selection: const TextSelection.collapsed(offset: 0),
          readOnly: true,
        );
      }
    } catch (_) {
      qcC = QuillController(
        document: Document()..insert(0, '$raw\n'),
        selection: const TextSelection.collapsed(offset: 0),
        readOnly: true,
      );
    }

    super.initState();
  }

  @override
  void dispose() {
    sc.removeListener(sl);
    sc.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final eventImages = widget.event.images;
    final sliderItems = eventImages.isNotEmpty
        ? eventImages.map((image) {
            return CachedNetworkImage(
              imageUrl: image.path,
              fit: BoxFit.cover,
              width: double.infinity,
              placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) => Image.asset(
                'assets/images/default_image.png',
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            );
          }).toList()
        : [
            Image.asset(
              'assets/images/default_image.png',
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ];

    return Scaffold(
      body: NestedScrollView(
        controller: sc,
        headerSliverBuilder: (BuildContext context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 265.0,
              backgroundColor: isTitleVisible ? ColorResources.transparent : ColorResources.black,
              floating: false,
              pinned: true,
              centerTitle: true,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                titlePadding: EdgeInsets.zero,
                background: CarouselSlider(
                  options: CarouselOptions(viewportFraction: 1.0, height: 265.0, autoPlay: true),
                  items: sliderItems,
                ),
                title: isTitleVisible
                    ? Container(
                        margin: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 10.0),
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha((0.5 * 255).round()),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.event.title,
                              style: montserratRegular.copyWith(
                                color: Colors.white,
                                fontSize: 13.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              DateFormat("yyyy-MM-dd").format(widget.event.createdAt!),
                              style: montserratRegular.copyWith(color: Colors.white, fontSize: 9.0),
                            ),
                          ],
                        ),
                      )
                    : Container(
                        margin: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 18.0),
                        child: Text(
                          widget.event.title,
                          style: montserratRegular.copyWith(
                            color: ColorResources.white,
                            fontSize: 13.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ),
              leading: Container(
                color: Colors.black.withAlpha((0.5 * 255).round()),
                child: CupertinoNavigationBarBackButton(
                  color: ColorResources.white,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
          ];
        },
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.only(top: 16.0, bottom: 16.0, left: 16.0, right: 16.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  if ((widget.event.latitude != null && widget.event.longitude != null) ||
                      (widget.event.mapsUrl ?? '').trim().isNotEmpty)
                    Container(
                      width: double.infinity,
                      height: 220,
                      margin: const EdgeInsets.only(bottom: 12),
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Stack(
                        children: [
                          FlutterMap(
                            options: MapOptions(
                              initialCenter: LatLng(
                                widget.event.latitude ?? -6.2,
                                widget.event.longitude ?? 106.816666,
                              ),
                              initialZoom: 14,
                            ),
                            children: [
                              TileLayer(
                                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'com.example.flutter_event',
                              ),
                              if (widget.event.latitude != null && widget.event.longitude != null)
                                MarkerLayer(
                                  markers: [
                                    Marker(
                                      point: LatLng(widget.event.latitude!, widget.event.longitude!),
                                      width: 44,
                                      height: 44,
                                      child: const Icon(Icons.location_pin, color: Colors.red, size: 38),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                          Positioned(
                            right: 10,
                            bottom: 10,
                            child: FloatingActionButton.small(
                              heroTag: 'open-map-${widget.event.uid}',
                              backgroundColor: Colors.black87,
                              onPressed: () async {
                                final direct = (widget.event.mapsUrl ?? '').trim();
                                final fallback =
                                    'https://www.openstreetmap.org/?mlat=${widget.event.latitude}&mlon=${widget.event.longitude}#map=16/${widget.event.latitude}/${widget.event.longitude}';
                                final target = direct.isNotEmpty ? direct : fallback;
                                final uri = Uri.parse(target);
                                await launchUrl(uri, mode: LaunchMode.externalApplication);
                              },
                              child: const Icon(Icons.directions, color: Colors.white),
                            ),
                          ),
                          if ((widget.event.locationName ?? '').trim().isNotEmpty)
                            Positioned(
                              left: 8,
                              right: 8,
                              top: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  widget.event.locationName!,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: montserratRegular.copyWith(fontSize: 12.0, color: Colors.white),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  QuillEditor.basic(controller: qcC, config: const QuillEditorConfig()),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
