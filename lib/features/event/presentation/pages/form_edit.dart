import 'dart:convert';
import 'dart:developer';
import 'dart:io';

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
import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart';

import 'package:flutter_event/common/constants/remote_data_source_consts.dart';
import 'package:flutter_event/common/helpers/enum.dart';
import 'package:flutter_event/common/utils/color_resources.dart';
import 'package:flutter_event/common/utils/custom_themes.dart';

import 'package:flutter_event/features/event/presentation/provider/event_delete_image_notifier.dart';
import 'package:flutter_event/features/event/presentation/provider/event_store_image_notifier.dart';
import 'package:flutter_event/features/event/presentation/provider/event_detail_notifier.dart';
import 'package:flutter_event/features/event/presentation/provider/event_update_notifier.dart';

import 'package:flutter_event/features/event/data/models/event_detail.dart';

import 'package:flutter_event/shared/basewidgets/modal/modal.dart';

class FormEventEditPage extends StatefulWidget {
  static const String route = '/event-edit';

  final String id;
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

  String title = "";

  List<Media> images = [];

  List<int> idxDelImages = [];

  String startTimeDB = "";
  String endTimeDB = "";

  String startDateTimeDB = "";
  String endDateTimeDB = "";

  DateTime? startDateTime;
  DateTime? endDateTime;

  QuillController qcC = QuillController.basic();
  FocusNode qcFn = FocusNode();

  bool isLoading = true;

  Future<void> getData() async {
    await eventDetailNotifier.eventDetail(id: widget.id);
    if (!mounted) return;

    final entity = eventDetailNotifier.entity;

    title = entity.title ?? "";

    startTimeDB = entity.startTime ?? "";
    endTimeDB = entity.endTime ?? "";

    startDateTimeDB = entity.startDate ?? "";
    endDateTimeDB = entity.endDate ?? "";

    images = entity.media ?? []; 
 
    qcC.document = Document.fromJson(jsonDecode(entity.caption.toString()));
    qcC.readOnly = false;

    setState(() {
      isLoading = false;
    });
  }

  String formatDate(DateTime? dateTime) => dateTime == null ? "" : DateFormat('yyyy-MM-dd').format(dateTime);
  String formatTime(DateTime? dateTime) => dateTime == null ? "" : DateFormat('HH:mm').format(dateTime);

  Future<void> pickImages() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        List<File> newImages = [];

        // Create a set of existing image hashes for quick lookup
        Set<String> existingHashes = {};

        // Hash existing images in `images`
        for (var media in images) {
          if (media.file != null) {
            final existingBytes = await media.file!.readAsBytes();
            final hash = md5.convert(existingBytes).toString();
            existingHashes.add(hash);
          }
        }

        for (var file in result.files) {

          if (images.length + newImages.length >= 5) {
            ShowSnackbar.snackbarErr("Max File: 5 Item");
            break;
          }

          final fileBytes = file.bytes;
          if (fileBytes == null) continue;

          final fileHash = md5.convert(fileBytes).toString();

          // Check if hash already exists
          if (existingHashes.contains(fileHash)) {
            continue; // Skip duplicate
          }

          // Add new file
          File newFile;
          if (file.path != null) {
            newFile = File(file.path!);
          } else {
            final tempDir = Directory.systemTemp;
            newFile = await File('${tempDir.path}/${file.name}').writeAsBytes(fileBytes);
          }

          newImages.add(newFile);
          existingHashes.add(fileHash); // Prevent same hash within same pick
        }

        // Add new images to your `images` list
        if (newImages.isNotEmpty) {
          setState(() {
            for (File newImage in newImages) {
              images.add(Media(id: 444, path: newImage.path, file: newImage, type: "file"));
            }
          });
        }
      }
    } catch (e, st) {
      log("File Picker Error: $e");
      log("Stacktrace: $st");
      if (mounted) {
        ShowSnackbar.snackbarErr("Error picking image: $e");
      }
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

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(now),
    );
    if (time == null) return;

    final selected = DateTime(date.year, date.month, date.day, time.hour, time.minute);

    setState(() {
      isStart ? startDateTime = selected : endDateTime = selected;
    });
  }

  Future<void> submit() async {
    
    if(title.trim() == "") {
      ShowSnackbar.snackbarErr("Field title is required");
      return; 
    }
    
    if (qcC.document.toPlainText().trim().isEmpty) {
      ShowSnackbar.snackbarErr("Field content is required");
      return;
    }

    for (int id in idxDelImages) {
      await eventDeleteImageNotifier.eventDeleteImage(eventId: id.toString());
    }

    if(images.isNotEmpty) {
      CloudinaryPublic cloudinary = CloudinaryPublic(
        RemoteDataSourceConsts.cloudName, 
        RemoteDataSourceConsts.folderCloudName, 
        cache: false
      );
      
      for (Media file in images) {
        if(file.type == "file") {
          try {
            CloudinaryResponse? response = await cloudinary.uploadFileInChunks(
              CloudinaryFile.fromFile(file.file!.path, resourceType: CloudinaryResourceType.Image),
              onProgress: (int count, int total) {
                var progress = (count / total) * 100;
                log(progress.toString());
              },
            );
            await eventStoreImageNotifier.eventStoreImage(
              eventId: widget.id, 
              path: response!.secureUrl
            );
          } on DioException catch(e) {
            log(e.response!.data.toString());
          } catch(e, stacktrace) {
            log(e.toString());
            log(stacktrace.toString());
          }
        }
      }
    }

    final caption = jsonEncode(qcC.document.toDelta().toJson());
    final captionHtml = QuillDeltaToHtmlConverter(qcC.document.toDelta().toJson()).convert();

    await eventUpdateNotifier.eventUpdate(
      id: widget.id,
      title: title,
      caption: caption,
      captionHtml: captionHtml,
      startDate: startDateTime == null ? startDateTimeDB : formatDate(startDateTime),
      startTime: startDateTime == null ? startTimeDB : formatTime(startDateTime),
      endDate: endDateTime == null ? endDateTimeDB : formatDate(endDateTime),
      endTime: endDateTime == null ? endTimeDB : formatTime(endDateTime),
    );

    if (mounted) {
      Navigator.pop(context, "refetch");
    }
  }

  @override
  void initState() {
    super.initState();

    eventDetailNotifier = context.read<EventDetailNotifier>();
    eventUpdateNotifier = context.read<EventUpdateNotifier>();
    eventStoreImageNotifier = context.read<EventStoreImageNotifier>();
    eventDeleteImageNotifier = context.read<EventDeleteImageNotifier>();

    Future.microtask(() => getData());
  }

  @override
  void dispose() {
    qcC.dispose();
    qcFn.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Edit Event',
          style: montserratRegular.copyWith(
            fontSize: 13.0,
          ),
        ),
        leading: CupertinoNavigationBarBackButton(
          color: ColorResources.black,
          onPressed: () {
            Navigator.pop(context);
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
                initialValue: title,
                style: montserratRegular.copyWith(
                  fontSize: 13.0
                ),
                decoration: InputDecoration(
                  labelText: 'Title',
                  labelStyle: montserratRegular.copyWith(
                    fontSize: 13.0
                  )
                ),
                onChanged: (String value) => title = value,
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [

                  Container(
                    width: 100.0,
                    margin: const EdgeInsets.only(
                      top: 8.0,
                      bottom: 8.0
                    ),
                    child: InkWell(
                      onTap: () async {
                        GDialog.quillToolbar(controller: qcC);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: Row(
                          children: [
                            Text("Toolbar",
                              style: montserratRegular.copyWith(
                                fontSize: 13.0,
                                color: ColorResources.black
                              ),
                            ),
                            const SizedBox(width: 8.0),
                            const Icon(Icons.edit_document,
                              size: 16.0,
                            ),
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
                  config:  QuillEditorConfig(
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
                        null
                      )
                    ),
                    padding: const EdgeInsets.all(10.0)
                  )
                ),
              ),

              const SizedBox(height: 16.0),

              ElevatedButton.icon(
                icon: const Icon(
                  Icons.image,
                  color: ColorResources.black,
                ),
                label: Text("Pick Images",
                  style: montserratRegular.copyWith(
                    fontSize: 14.0,
                    color: ColorResources.black,
                  ),
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
                    final imageFile = entry.value;

                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: imageFile.type == "file" 
                          ? Image.file(
                              imageFile.file!,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            )
                          : Image.network(
                              imageFile.path,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                images.removeAt(index);
                              });
                              if(imageFile.type == "network") {
                                idxDelImages.add(imageFile.id);
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),

              const SizedBox(height: 16.0),

              ListTile(
                title: startDateTime == null 
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                    
                      Text("Start DateTime",
                        style: montserratRegular.copyWith(
                          fontSize: 14.0
                        ),
                      ),
                    
                      const SizedBox(height: 8.0),

                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: const BoxDecoration(
                              color: ColorResources.black,
                            ),
                            child: Text(startDateTimeDB,
                              style: montserratRegular.copyWith(
                                fontSize: 13.0,
                                color: ColorResources.white
                              ),
                            )
                          ),
                          const SizedBox(width: 10.0),
                          Container(
                            padding: const EdgeInsets.all(8.0),
                             decoration: const BoxDecoration(
                              color: ColorResources.black,
                            ),
                            child: Text(startTimeDB,
                              style: montserratRegular.copyWith(
                                fontSize: 13.0,
                                color: ColorResources.white
                              ),
                            )
                          )
                        ],
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      
                      Text("Start DateTime",
                        style: montserratRegular.copyWith(
                          fontSize: 14.0
                        ),
                      ),
                    
                      const SizedBox(height: 8.0),

                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: const BoxDecoration(
                              color: ColorResources.black,
                            ),
                            child: Text(formatDate(startDateTime),
                              style: montserratRegular.copyWith(
                                fontSize: 13.0,
                                color: ColorResources.white
                              ),
                            )
                          ),
                          const SizedBox(width: 10.0),
                          Container(
                            padding: const EdgeInsets.all(8.0),
                             decoration: const BoxDecoration(
                              color: ColorResources.black,
                            ),
                            child: Text(formatTime(startDateTime),
                              style: montserratRegular.copyWith(
                                fontSize: 13.0,
                                color: ColorResources.white
                              ),
                            )
                          )
                        ],
                      ),
                    ],
                  ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => pickDateTime(isStart: true),
              ),
             
              ListTile(
                title: endDateTime == null 
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [

                    Text("End DateTime",
                      style: montserratRegular.copyWith(
                        fontSize: 14.0
                      ),
                    ),
                    
                    const SizedBox(height: 8.0),
                    
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: const BoxDecoration(
                            color: ColorResources.black,
                          ),
                          child: Text(endDateTimeDB,
                            style: montserratRegular.copyWith(
                              fontSize: 13.0,
                              color: ColorResources.white
                            ),
                          )
                        ),
                        const SizedBox(width: 10.0),
                        Container(
                          padding: const EdgeInsets.all(8.0),
                            decoration: const BoxDecoration(
                            color: ColorResources.black,
                          ),
                          child: Text(endTimeDB,
                            style: montserratRegular.copyWith(
                              fontSize: 13.0,
                              color: ColorResources.white
                            ),
                          )
                        )
                      ],
                    ),
                  ],
                )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                    
                    Text("End DateTime",
                      style: montserratRegular.copyWith(
                        fontSize: 14.0
                      ),
                    ),
                    
                    const SizedBox(height: 8.0),
                    
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: const BoxDecoration(
                            color: ColorResources.black,
                          ),
                          child: Text(formatDate(endDateTime),
                            style: montserratRegular.copyWith(
                              fontSize: 13.0,
                              color: ColorResources.white
                            ),
                          )
                        ),
                        const SizedBox(width: 10.0),
                        Container(
                          padding: const EdgeInsets.all(8.0),
                          decoration: const BoxDecoration(
                            color: ColorResources.black,
                          ),
                          child: Text(formatTime(endDateTime),
                            style: montserratRegular.copyWith(
                              fontSize: 13.0,
                              color: ColorResources.white
                            ),
                          )
                        )
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
                    child: SpinKitFadingCircle(
                      color: ColorResources.black,
                      size: 25.0
                    ),
                  )
                : Text('Submit',
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
