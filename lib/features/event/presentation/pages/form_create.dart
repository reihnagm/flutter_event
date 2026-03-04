import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:developer';

import 'package:intl/intl.dart';
import 'package:flutter_event/snackbar.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:crypto/crypto.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import 'package:flutter_event/common/utils/color_resources.dart';
import 'package:flutter_event/common/utils/custom_themes.dart';
import 'package:flutter_event/common/helpers/enum.dart';
import 'package:flutter_event/common/constants/remote_data_source_consts.dart';

import 'package:flutter_event/features/event/presentation/provider/event_store_notifier.dart';

import 'package:flutter_event/shared/basewidgets/modal/modal.dart';
import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart';

class FormEventCreatePage extends StatefulWidget {
  static const String route = '/event-create';

  const FormEventCreatePage({super.key});

  @override
  State<FormEventCreatePage> createState() => FormEventCreatePageState();
}

class FormEventCreatePageState extends State<FormEventCreatePage> {
  late EventStoreNotifier eventStoreNotifier;
  // late EventStoreImageNotifier eventStoreImageNotifier;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  QuillController qcC = QuillController.basic();
  FocusNode qcFn = FocusNode();

  String title = "";
  String locationName = "";
  String latitudeText = "";
  String longitudeText = "";
  DateTime? startDateTime;
  DateTime? endDateTime;
  List<File> images = [];
  LatLng mapPoint = const LatLng(-6.2, 106.816666);
  final TextEditingController locationSearchC = TextEditingController();
  List<Map<String, dynamic>> placeSuggestions = [];
  Timer? _placeDebounce;
  bool isSearchingPlace = false;

  String formatDate(DateTime? dateTime) {
    if (dateTime == null) return 'Select DateTime';
    return DateFormat('yyyy-MM-dd').format(dateTime);
  }

  String formatTime(DateTime? dateTime) {
    if (dateTime == null) return 'Select DateTime';
    return DateFormat('HH:mm').format(dateTime);
  }

  Future<void> pickDateTime({required bool isStart}) async {
    DateTime now = DateTime.now();

    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );

    if (date == null) return;

    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(now));

    if (time == null) return;

    final selected = DateTime(date.year, date.month, date.day, time.hour, time.minute);

    setState(() {
      if (isStart) {
        startDateTime = selected;
      } else {
        endDateTime = selected;
      }
    });
  }

  Future<void> pickImages() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
      withData: true,
    );

    if (result != null && result.files.isNotEmpty) {
      List<File> newImages = [];

      for (var file in result.files) {
        final fileBytes = file.bytes;
        if (fileBytes == null) continue;

        final fileHash = md5.convert(fileBytes).toString();

        bool isDuplicate = false;

        for (var existingImage in images) {
          final existingFileBytes = await existingImage.readAsBytes();
          final existingFileHash = md5.convert(existingFileBytes).toString();

          if (existingFileHash == fileHash) {
            isDuplicate = true;
            break;
          }
        }

        if (!isDuplicate) {
          if (file.path != null) {
            newImages.add(File(file.path!));
          } else {
            final tempDir = Directory.systemTemp;
            final tempFile = await File('${tempDir.path}/${file.name}').writeAsBytes(file.bytes!);
            newImages.add(tempFile);
          }
        }
      }

      if (newImages.isNotEmpty) {
        setState(() {
          images.addAll(newImages);
        });
      }
    }
  }

  Future<void> searchPlaces(String query) async {
    final q = query.trim();
    _placeDebounce?.cancel();

    if (q.length < 3) {
      setState(() {
        isSearchingPlace = false;
        placeSuggestions = [];
      });
      return;
    }

    _placeDebounce = Timer(const Duration(milliseconds: 450), () async {
      if (!mounted) return;
      setState(() => isSearchingPlace = true);

      try {
        List<Map<String, dynamic>> mapped = [];

        // 1) Nominatim
        try {
          final res = await Dio().get(
            'https://nominatim.openstreetmap.org/search',
            queryParameters: {
              'q': q,
              'format': 'json',
              'limit': 5,
            },
            options: Options(headers: {
              'User-Agent': 'BantuMasjidEventApp/1.0',
              'Accept': 'application/json',
            }),
          );

          final raw = res.data;
          final List list = raw is List
              ? raw
              : (raw is String ? (jsonDecode(raw) as List? ?? []) : []);

          for (final item in list) {
            final m = (item is Map) ? item : null;
            if (m == null) continue;
            final lat = double.tryParse('${m['lat'] ?? ''}');
            final lon = double.tryParse('${m['lon'] ?? ''}');
            if (lat == null || lon == null) continue;
            mapped.add({
              'name': '${m['display_name'] ?? ''}',
              'lat': lat,
              'lon': lon,
            });
          }
        } catch (_) {}

        // 2) Photon fallback
        if (mapped.isEmpty) {
          final res2 = await Dio().get(
            'https://photon.komoot.io/api/',
            queryParameters: {'q': q, 'limit': 5},
            options: Options(headers: {'Accept': 'application/json'}),
          );

          final raw2 = res2.data;
          final Map data = raw2 is Map
              ? raw2
              : (raw2 is String ? (jsonDecode(raw2) as Map? ?? {}) : {});
          final feats = (data['features'] as List?) ?? [];

          for (final f in feats) {
            final fm = (f is Map) ? f : null;
            if (fm == null) continue;
            final props = (fm['properties'] is Map) ? fm['properties'] as Map : {};
            final geom = (fm['geometry'] is Map) ? fm['geometry'] as Map : {};
            final coords = (geom['coordinates'] as List?) ?? [];
            final lon = coords.isNotEmpty ? (coords[0] as num?)?.toDouble() : null;
            final lat = coords.length > 1 ? (coords[1] as num?)?.toDouble() : null;
            if (lat == null || lon == null) continue;

            final name = [
              props['name'],
              props['street'],
              props['district'],
              props['city'],
              props['state'],
            ].where((x) => (x ?? '').toString().trim().isNotEmpty).join(', ');

            mapped.add({'name': name, 'lat': lat, 'lon': lon});
          }
        }

        if (!mounted) return;
        setState(() {
          placeSuggestions = mapped;
          isSearchingPlace = false;
        });
      } catch (_) {
        if (!mounted) return;
        setState(() {
          placeSuggestions = [];
          isSearchingPlace = false;
        });
      }
    });
  }


  void pickPlace(Map<String, dynamic> place) {
    final lat = place['lat'] as double;
    final lon = place['lon'] as double;
    setState(() {
      mapPoint = LatLng(lat, lon);
      latitudeText = lat.toStringAsFixed(6);
      longitudeText = lon.toStringAsFixed(6);
      locationName = place['name']?.toString() ?? '';
      locationSearchC.text = locationName;
      placeSuggestions = [];
    });
  }

  Future<void> submit() async {
    if (title.trim() == "") {
      ShowSnackbar.snackbarErr("Field title is required");
      return;
    }

    if (qcC.document.toPlainText().trim().isEmpty) {
      ShowSnackbar.snackbarErr("Field content is required");
      return;
    }

    if (startDateTime == null) {
      ShowSnackbar.snackbarErr("Field start date time is required");
      return;
    }

    if (endDateTime == null) {
      ShowSnackbar.snackbarErr("Field end date time is required");
      return;
    }

    String eventId = const Uuid().v4();

    String content = jsonEncode(qcC.document.toDelta().toJson());
    String contentHtml = QuillDeltaToHtmlConverter(qcC.document.toDelta().toJson()).convert();

    final List<String> imageUrls = [];
    if (images.isNotEmpty) {
      try {
        final cloudinary = CloudinaryPublic(
          RemoteDataSourceConsts.cloudName,
          RemoteDataSourceConsts.folderCloudName,
          cache: false,
        );

        for (final file in images) {
          final response = await cloudinary.uploadFileInChunks(
            CloudinaryFile.fromFile(file.path, resourceType: CloudinaryResourceType.Image),
            onProgress: (int count, int total) {
              final progress = (count / total) * 100;
              log('upload image: ${progress.toStringAsFixed(0)}%');
            },
          );
          imageUrls.add(response!.secureUrl);
        }
      } catch (e, stacktrace) {
        log(e.toString());
        log(stacktrace.toString());
        ShowSnackbar.snackbarErr("Upload gambar gagal: $e");
        return;
      }
    }

    final latitude = double.tryParse(latitudeText.trim());
    final longitude = double.tryParse(longitudeText.trim());

    await eventStoreNotifier.eventStore(
      id: eventId,
      title: title,
      content: content,
      contentHtml: contentHtml,
      startDate: formatDate(startDateTime),
      startTime: formatTime(startDateTime),
      endDate: formatDate(endDateTime),
      endTime: formatTime(endDateTime),
      locationName: locationName.trim().isEmpty ? null : locationName.trim(),
      latitude: latitude,
      longitude: longitude,
      mapsUrl: (latitude != null && longitude != null) ? 'https://www.openstreetmap.org/?mlat=${latitude}&mlon=${longitude}#map=16/${latitude}/${longitude}' : null,
      images: imageUrls,
    );

    if (mounted) {
      Navigator.pop(context, "refetch");
    }
  }

  @override
  void initState() {
    super.initState();

    eventStoreNotifier = context.read<EventStoreNotifier>();
    // eventStoreImageNotifier = context.read<EventStoreImageNotifier>();
  }

  @override
  void dispose() {
    locationSearchC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Create Event', style: montserratRegular.copyWith(fontSize: 13.0)),
        leading: CupertinoNavigationBarBackButton(
          color: ColorResources.black,
          onPressed: () {
            Navigator.pop(context, "refetch");
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: ListView(
            children: [
              TextFormField(
                style: montserratRegular.copyWith(fontSize: 13.0),
                decoration: InputDecoration(
                  labelText: 'Title',
                  labelStyle: montserratRegular.copyWith(fontSize: 13.0),
                ),
                onChanged: (String value) => title = value,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: locationSearchC,
                style: montserratRegular.copyWith(fontSize: 13.0),
                decoration: InputDecoration(
                  labelText: 'Cari lokasi (autocomplete)',
                  labelStyle: montserratRegular.copyWith(fontSize: 13.0),
                ),
                onChanged: (v) {
                  locationName = v;
                  searchPlaces(v);
                },
              ),
              if (isSearchingPlace) const Padding(
                padding: EdgeInsets.only(top: 8),
                child: LinearProgressIndicator(minHeight: 2),
              ),
              if (placeSuggestions.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  decoration: BoxDecoration(border: Border.all(color: Colors.black12)),
                  child: Column(
                    children: placeSuggestions
                        .map(
                          (p) => ListTile(
                            dense: true,
                            title: Text(p['name'], maxLines: 2, overflow: TextOverflow.ellipsis),
                            onTap: () => pickPlace(p),
                          ),
                        )
                        .toList(),
                  ),
                ),
              const SizedBox(height: 8),
              SizedBox(
                height: 220,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: mapPoint,
                      initialZoom: 13,
                      onTap: (tapPos, point) {
                        setState(() {
                          mapPoint = point;
                          latitudeText = point.latitude.toStringAsFixed(6);
                          longitudeText = point.longitude.toStringAsFixed(6);
                        });
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.flutter_event',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: mapPoint,
                            width: 40,
                            height: 40,
                            child: const Icon(Icons.location_pin, color: Colors.red, size: 36),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text('Lat: $latitudeText | Lng: $longitudeText', style: montserratRegular.copyWith(fontSize: 12)),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 100.0,
                    margin: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                    child: InkWell(
                      onTap: () async {
                        GDialog.quillToolbar(controller: qcC);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Row(
                          children: [
                            Text(
                              "Toolbar",
                              style: montserratRegular.copyWith(
                                fontSize: 13.0,
                                color: ColorResources.black,
                              ),
                            ),
                            const SizedBox(width: 8.0),
                            const Icon(Icons.edit_document, size: 16.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 2.0),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: QuillEditor.basic(
                  controller: qcC,
                  focusNode: qcFn,
                  config: QuillEditorConfig(
                    minHeight: 220.0,
                    placeholder: "Add Content",
                    customStyles: DefaultStyles(
                      placeHolder: DefaultTextBlockStyle(
                        montserratRegular.copyWith(
                          fontSize: 13.0,
                          fontWeight: FontWeight.normal,
                          color: Colors.grey,
                        ),
                        const HorizontalSpacing(0, 0),
                        const VerticalSpacing(0, 0),
                        const VerticalSpacing(0, 0),
                        null,
                      ),
                    ),
                    padding: const EdgeInsets.all(10.0),
                  ),
                ),
              ),

              const SizedBox(height: 16.0),

              ListTile(
                title: startDateTime == null
                    ? Text('Start DateTime', style: montserratRegular.copyWith(fontSize: 14.0))
                    : Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: const BoxDecoration(color: ColorResources.black),
                            child: Text(
                              formatDate(startDateTime),
                              style: montserratRegular.copyWith(
                                fontSize: 13.0,
                                color: ColorResources.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10.0),
                          Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: const BoxDecoration(color: ColorResources.black),
                            child: Text(
                              formatTime(startDateTime),
                              style: montserratRegular.copyWith(
                                fontSize: 13.0,
                                color: ColorResources.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => pickDateTime(isStart: true),
              ),

              ListTile(
                title: endDateTime == null
                    ? Text('End DateTime', style: montserratRegular.copyWith(fontSize: 14.0))
                    : Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: const BoxDecoration(color: ColorResources.black),
                            child: Text(
                              formatDate(endDateTime),
                              style: montserratRegular.copyWith(
                                fontSize: 13.0,
                                color: ColorResources.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10.0),
                          Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: const BoxDecoration(color: ColorResources.black),
                            child: Text(
                              formatTime(endDateTime),
                              style: montserratRegular.copyWith(
                                fontSize: 13.0,
                                color: ColorResources.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => pickDateTime(isStart: false),
              ),

              const SizedBox(height: 16.0),

              ElevatedButton.icon(
                icon: const Icon(Icons.image, color: ColorResources.black),
                label: Text(
                  "Pick Images",
                  style: montserratRegular.copyWith(fontSize: 14.0, color: ColorResources.black),
                ),
                onPressed: pickImages,
              ),

              const SizedBox(height: 10.0),

              if (images.isNotEmpty)
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: images.asMap().entries.map((entry) {
                    int index = entry.key;
                    File imageFile = entry.value;

                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.file(imageFile, width: 100, height: 100, fit: BoxFit.cover),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                images.removeAt(index);
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close, color: Colors.white, size: 20),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: submit,
                child: context.watch<EventStoreNotifier>().state == ProviderState.loading
                    ? const Center(
                        child: SpinKitFadingCircle(color: ColorResources.black, size: 25.0),
                      )
                    : Text(
                        'Submit',
                        style: montserratRegular.copyWith(
                          fontSize: 16.0,
                          color: ColorResources.black,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
