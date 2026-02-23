import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter_quill/quill_delta.dart';
import 'package:intl/intl.dart';

import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_event/snackbar.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart';

import 'package:flutter_event/common/constants/remote_data_source_consts.dart';
import 'package:flutter_event/common/helpers/enum.dart';
import 'package:flutter_event/common/utils/color_resources.dart';
import 'package:flutter_event/common/utils/custom_themes.dart';

import 'package:flutter_event/features/event/presentation/provider/event_delete_image_notifier.dart';
import 'package:flutter_event/features/event/presentation/provider/event_store_image_notifier.dart';
import 'package:flutter_event/features/event/presentation/provider/event_detail_notifier.dart';
import 'package:flutter_event/features/event/presentation/provider/event_update_notifier.dart';

import 'package:flutter_event/shared/basewidgets/modal/modal.dart';

// NOTE: Media class kamu sudah dipakai sebelumnya:
// Media(id: 444, path: newImage.path, file: newImage, type: "file")
// Media(id: networkId, path: url, type: "network")
//
// Pastikan Media punya fields: int id; String path; File? file; String type;
import 'package:flutter_event/features/event/data/models/event_detail.dart';

class FormEventEditPage extends StatefulWidget {
  static const String route = '/event-edit';

  final String
  id; // dari list kamu kirim event.id / atau uid, tapi sekarang ini dipakai buat detail usecase
  const FormEventEditPage({required this.id, super.key});

  @override
  State<FormEventEditPage> createState() => FormEventEditPageState();
}

class FormEventEditPageState extends State<FormEventEditPage> {
  late EventDetailNotifier eventDetailNotifier;
  late EventUpdateNotifier eventUpdateNotifier;
  late EventStoreImageNotifier eventStoreImageNotifier;
  late EventDeleteImageNotifier eventDeleteImageNotifier;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController titleC = TextEditingController();

  String title = "";
  String eventUid = ""; // penting untuk delete/add image via uid

  List<EventImage> images = [];
  List<int> idxDelImages = [];

  DateTime? startDateTimeDB;
  DateTime? endDateTimeDB;

  DateTime? startDateTime;
  DateTime? endDateTime;

  QuillController qcC = QuillController.basic();
  FocusNode qcFn = FocusNode();

  bool isLoading = true;
  int _carouselIndex = 0;

  // UI helper
  String _fmtDate(DateTime? dt) => dt == null ? "" : DateFormat('yyyy-MM-dd').format(dt.toLocal());
  String _fmtTime(DateTime? dt) => dt == null ? "" : DateFormat('HH:mm').format(dt.toLocal());

  // backend Go kamu menerima "2006-01-02 15:04:05" atau RFC3339
  // paling aman kirim RFC3339 UTC
  // String? _toRFC3339Utc(DateTime? dt) => dt == null ? null : dt.toUtc().toIso8601String();

  Future<void> getData() async {
    await eventDetailNotifier.eventDetail(id: widget.id);
    if (!mounted) return;

    final entity = eventDetailNotifier.entity; // EventDetail?
    if (entity == null) {
      setState(() => isLoading = false);
      return;
    }

    // ✅ sesuai model baru
    eventUid = entity.uid;
    title = entity.title;
    titleC.text = entity.title;

    startDateTimeDB = entity.startDate;
    endDateTimeDB = entity.endDate;

    // ✅ images sekarang List<EventImage> -> convert jadi Media(network)
    images = entity.images;

    // ✅ content string -> quill doc simple
    // (kalau kamu ingin preserve formatting, backend harus simpan delta. sekarang backend hanya simpan string)
    final contentText = entity.content.trim();
    qcC = QuillController(
      // ✅ tambah newline agar quill stabil
      document: Document.fromDelta(Delta()..insert('$contentText\n')),
      selection: const TextSelection.collapsed(offset: 0),
    );

    qcC.readOnly = false;

    setState(() {
      isLoading = false;
      _carouselIndex = 0;
    });
  }

  Future<void> pickImages() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        List<File> newImages = [];
        Set<String> existingHashes = {};

        // hash existing picked files only
        // for (var media in images) {
        //   if (media.file != null) {
        //     final b = await media.file!.readAsBytes();
        //     existingHashes.add(md5.convert(b).toString());
        //   }
        // }

        for (var file in result.files) {
          if (images.length + newImages.length >= 5) {
            ShowSnackbar.snackbarErr("Max File: 5 Item");
            break;
          }

          final fileBytes = file.bytes;
          if (fileBytes == null) continue;

          final fileHash = md5.convert(fileBytes).toString();
          if (existingHashes.contains(fileHash)) continue;

          File newFile;
          if (file.path != null) {
            newFile = File(file.path!);
          } else {
            final tempDir = Directory.systemTemp;
            newFile = await File('${tempDir.path}/${file.name}').writeAsBytes(fileBytes);
          }

          newImages.add(newFile);
          existingHashes.add(fileHash);
        }

        // if (newImages.isNotEmpty) {
        //   setState(() {
        //     for (final f in newImages) {
        //       images.add(Media(id: 444, path: f.path, file: f, type: "file"));
        //     }
        //   });
        // }
      }
    } catch (e, st) {
      log("File Picker Error: $e");
      log("Stacktrace: $st");
      if (mounted) ShowSnackbar.snackbarErr("Error picking image: $e");
    }
  }

  Future<void> pickDateTime({required bool isStart}) async {
    final now = DateTime.now();

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

  void _removeImageAt(int index) {
    if (index < 0 || index >= images.length) return;

    // final img = images[index];

    setState(() {
      images.removeAt(index);

      // ✅ hanya network images punya id server -> mark untuk delete
      // if (img.type == "network") {
      //   idxDelImages.add(img.id);
      // }

      if (_carouselIndex >= images.length) {
        _carouselIndex = images.isEmpty ? 0 : images.length - 1;
      }
    });
  }

  Future<void> submit() async {
    // ambil title dari controller biar pasti sesuai UI
    title = titleC.text;

    if (title.trim().isEmpty) {
      ShowSnackbar.snackbarErr("Field title is required");
      return;
    }

    final contentPlain = qcC.document.toPlainText().trim();
    if (contentPlain.isEmpty) {
      ShowSnackbar.snackbarErr("Field content is required");
      return;
    }

    if (eventUid.trim().isEmpty) {
      ShowSnackbar.snackbarErr("Event UID tidak ditemukan");
      return;
    }

    final finalStart = startDateTime ?? startDateTimeDB;
    final finalEnd = endDateTime ?? endDateTimeDB;

    if (finalStart != null && finalEnd != null && finalEnd.isBefore(finalStart)) {
      ShowSnackbar.snackbarErr("End datetime harus setelah start datetime");
      return;
    }

    // 1) delete images yang dihapus user
    // for (final imageId in idxDelImages) {
    // await eventDeleteImageNotifier.eventDeleteImage(uid: eventUid, imageId: imageId);

    // optional: kalau kamu punya state error di notifier, bisa stop di sini
    // if (eventDeleteImageNotifier.state == ProviderState.error) {
    //   ShowSnackbar.snackbarErr("Gagal hapus image");
    //   return;
    // }
    // }

    // 2) upload file baru -> add image
    // final fileImages = images.where((m) => m.type == "file" && m.file != null).toList();
    // if (fileImages.isNotEmpty) {
    //   final cloudinary = CloudinaryPublic(
    //     RemoteDataSourceConsts.cloudName,
    //     RemoteDataSourceConsts.folderCloudName,
    //     cache: false,
    //   );

    // for (final m in fileImages) {
    //   try {
    //     final res = await cloudinary.uploadFileInChunks(
    //       CloudinaryFile.fromFile(m.file!.path, resourceType: CloudinaryResourceType.Image),
    //       onProgress: (count, total) {
    //         final progress = (count / total) * 100;
    //         log(progress.toString());
    //       },
    //     );

    //     await eventStoreImageNotifier.eventStoreImage(uid: eventUid, path: res.secureUrl);
    //   } on DioException catch (e) {
    //     log(e.response?.data.toString() ?? "DioException");
    //   } catch (e, st) {
    //     log(e.toString());
    //     log(st.toString());
    //   }
    // }
    // }

    // 3) update event: title, content, start_date, end_date
    // await eventUpdateNotifier.eventUpdate(
    // kalau backend update pakai uid, kamu bisa kirim eventUid di sini
    //   id: widget.id,
    //   title: title.trim(),
    //   content: contentPlain,
    //   startDate: _toRFC3339Utc(finalStart),
    //   endDate: _toRFC3339Utc(finalEnd),
    // );

    if (mounted) Navigator.pop(context, "refetch");
  }

  @override
  void initState() {
    super.initState();
    eventDetailNotifier = context.read<EventDetailNotifier>();
    eventUpdateNotifier = context.read<EventUpdateNotifier>();
    eventStoreImageNotifier = context.read<EventStoreImageNotifier>();
    eventDeleteImageNotifier = context.read<EventDeleteImageNotifier>();
    Future.microtask(getData);
  }

  @override
  void dispose() {
    titleC.dispose();
    qcC.dispose();
    qcFn.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Edit Event', style: montserratRegular.copyWith(fontSize: 13.0)),
        leading: CupertinoNavigationBarBackButton(
          color: ColorResources.black,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: titleC,
                style: montserratRegular.copyWith(fontSize: 13.0),
                decoration: InputDecoration(
                  labelText: 'Title',
                  labelStyle: montserratRegular.copyWith(fontSize: 13.0),
                ),
                onChanged: (v) => title = v,
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 100.0,
                    margin: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                    child: InkWell(
                      onTap: () async => GDialog.quillToolbar(controller: qcC),
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
                    padding: const EdgeInsets.all(10.0),
                  ),
                ),
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
                _ImagesCarousel(
                  images: images,
                  index: _carouselIndex,
                  onIndexChanged: (i) => setState(() => _carouselIndex = i),
                  onRemove: _removeImageAt,
                ),

              const SizedBox(height: 16.0),

              ListTile(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Start DateTime", style: montserratRegular.copyWith(fontSize: 14.0)),
                    const SizedBox(height: 8.0),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: const BoxDecoration(color: ColorResources.black),
                          child: Text(
                            _fmtDate(startDateTime ?? startDateTimeDB),
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
                            _fmtTime(startDateTime ?? startDateTimeDB),
                            style: montserratRegular.copyWith(
                              fontSize: 13.0,
                              color: ColorResources.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => pickDateTime(isStart: true),
              ),

              ListTile(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("End DateTime", style: montserratRegular.copyWith(fontSize: 14.0)),
                    const SizedBox(height: 8.0),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: const BoxDecoration(color: ColorResources.black),
                          child: Text(
                            _fmtDate(endDateTime ?? endDateTimeDB),
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
                            _fmtTime(endDateTime ?? endDateTimeDB),
                            style: montserratRegular.copyWith(
                              fontSize: 13.0,
                              color: ColorResources.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => pickDateTime(isStart: false),
              ),

              const SizedBox(height: 20.0),

              ElevatedButton(
                onPressed: submit,
                child: context.watch<EventUpdateNotifier>().state == ProviderState.loading
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

class _ImagesCarousel extends StatelessWidget {
  final List<EventImage> images;
  final int index;
  final ValueChanged<int> onIndexChanged;
  final void Function(int index) onRemove;

  const _ImagesCarousel({
    required this.images,
    required this.index,
    required this.onIndexChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    const fallback = AssetImage('assets/images/default_image.png');

    Widget buildImage(EventImage m) {
      // if (m.type == "file" && m.file != null) {
      //   return Image.file(m.file!, width: double.infinity, height: 220, fit: BoxFit.cover);
      // }

      final url = m.path.trim();
      if (url.isEmpty) {
        return const Image(image: fallback, width: double.infinity, height: 220, fit: BoxFit.cover);
      }

      return Image.network(
        url,
        width: double.infinity,
        height: 220,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return const Image(
            image: fallback,
            width: double.infinity,
            height: 220,
            fit: BoxFit.cover,
          );
        },
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: CarouselSlider.builder(
                itemCount: images.length,
                itemBuilder: (context, i, realIndex) {
                  return Stack(
                    children: [
                      SizedBox.expand(child: buildImage(images[i])),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: GestureDetector(
                          onTap: () => onRemove(i),
                          child: Container(
                            padding: const EdgeInsets.all(6.0),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.55),
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: const Icon(Icons.close, color: Colors.white, size: 18),
                          ),
                        ),
                      ),
                    ],
                  );
                },
                options: CarouselOptions(
                  height: 220,
                  viewportFraction: 1.0,
                  enableInfiniteScroll: images.length > 1,
                  autoPlay: false,
                  onPageChanged: (i, _) => onIndexChanged(i),
                ),
              ),
            ),
            Positioned(
              left: 10,
              bottom: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.45),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  "${(index + 1).clamp(1, images.length)}/${images.length}",
                  style: montserratRegular.copyWith(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (images.length > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(images.length, (i) {
              final active = i == index;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: active ? 10 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: active ? ColorResources.black : Colors.grey.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(99),
                ),
              );
            }),
          ),
      ],
    );
  }
}
