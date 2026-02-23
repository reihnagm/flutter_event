import 'dart:convert';
import 'dart:io';

import 'package:intl/intl.dart';
import 'package:flutter_event/snackbar.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import 'package:flutter_event/common/utils/color_resources.dart';
import 'package:flutter_event/common/utils/custom_themes.dart';
import 'package:flutter_event/common/helpers/enum.dart';

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
  DateTime? startDateTime;
  DateTime? endDateTime;
  List<File> images = [];

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

    String caption = jsonEncode(qcC.document.toDelta().toJson());
    String captionHtml = QuillDeltaToHtmlConverter(qcC.document.toDelta().toJson()).convert();

    await eventStoreNotifier.eventStore(
      id: eventId,
      title: title,
      caption: caption,
      captionHtml: captionHtml,
      startDate: formatDate(startDateTime),
      startTime: formatTime(startDateTime),
      endDate: formatDate(endDateTime),
      endTime: formatTime(endDateTime),
    );

    if (images.isNotEmpty) {
      // CloudinaryPublic cloudinary = CloudinaryPublic(
      //   RemoteDataSourceConsts.cloudName,
      //   RemoteDataSourceConsts.folderCloudName,
      //   cache: false,
      // );

      // for (File file in images) {
      //   try {
      // CloudinaryResponse? response = await cloudinary.uploadFileInChunks(
      //   CloudinaryFile.fromFile(file.path, resourceType: CloudinaryResourceType.Image),
      //   onProgress: (int count, int total) {
      //     var progress = (count / total) * 100;
      //     log(progress.toString());
      //   },
      // );
      // await eventStoreImageNotifier.eventStoreImage(
      //   eventId: eventId,
      //   path: response!.secureUrl,
      // );
      //   } on DioException catch (e) {
      //     log(e.response!.data.toString());
      //   } catch (e, stacktrace) {
      //     log(e.toString());
      //     log(stacktrace.toString());
      //   }
      // }
    }

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
