import 'dart:convert';

import 'package:intl/intl.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_event/common/utils/color_resources.dart';

import 'package:flutter_event/common/utils/custom_themes.dart';
import 'package:flutter_quill/flutter_quill.dart';

class EventDetailPage extends StatefulWidget {
  static const String route = '/event-detail';

  final Map<String, dynamic> event;

  const EventDetailPage({
    required this.event,
    super.key
  });

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

    qcC.document = Document.fromJson(jsonDecode(widget.event["caption"]));
    qcC.readOnly = true;

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
    return Scaffold(
      body: NestedScrollView(
        controller: sc,
        headerSliverBuilder: (BuildContext context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 265.0,
              backgroundColor: isTitleVisible 
              ? ColorResources.transparent 
              : ColorResources.black ,
              floating: false,
              pinned: true,
              centerTitle: true,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                titlePadding: EdgeInsets.zero,
                background: CarouselSlider(
                  options: CarouselOptions(
                    viewportFraction: 1.0,
                    height: 265.0,
                    autoPlay: true,
                  ),
                  items: (widget.event['medias'] as List<dynamic>?)?.map((imageUrl) {
                    return CachedNetworkImage(
                      imageUrl: imageUrl["path"],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                      errorWidget: (context, url, error) => const Center(child: Icon(Icons.error)),
                    );
                  }).toList() ?? [
                    Container(
                      color: Colors.grey,
                      child: const Center(child: Text("No Images")),
                    )
                  ],
                ),
                title: isTitleVisible 
                  ? Container(
                      margin: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 10.0),
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha((0.5 * 255).round())
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(widget.event["name"],
                            style: montserratRegular.copyWith(
                              color: Colors.white,
                              fontSize: 13.0,
                              fontWeight: FontWeight.bold
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Text(DateFormat("yyyy-MM-dd").format(widget.event["createdAt"]), 
                            style: montserratRegular.copyWith(
                              color: Colors.white,
                              fontSize: 9.0
                            ),
                          )
                        ],
                      )
                    )
                  : Container(
                      margin: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 18.0),
                      child: Text(widget.event["name"],
                        style: montserratRegular.copyWith(
                          color: ColorResources.white,
                          fontSize: 13.0,
                          fontWeight: FontWeight.bold
                        ),
                      )
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
              padding: const EdgeInsets.only(
                top: 16.0,
                bottom: 16.0,
                left: 16.0,
                right: 16.0
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([

                  QuillEditor.basic(
                    controller: qcC,
                  )
            
                ])
              ),
            )

          ],
        )
      )
    );
  }

}