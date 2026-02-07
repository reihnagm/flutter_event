import 'package:dio/dio.dart';

import 'dart:developer';

import 'package:flutter_event/common/constants/remote_data_source_consts.dart';
import 'package:flutter_event/common/errors/exception.dart';

import 'package:flutter_event/features/event/data/models/event.dart';
import 'package:flutter_event/features/event/data/models/event_detail.dart';

abstract class EventRemoteDataSource {
  Future<EventModel> eventList();
  Future<void> eventStore({
    required String id,
    required String title, required String caption, required String captionHtml,
    required String startDate, required String startTime, 
    required String endDate, required String endTime
  });
  Future<void> eventUpdate({
    required String id,
    required String title, required String caption, required String captionHtml,
    required String startDate, required String startTime, 
    required String endDate, required String endTime
  });
  Future<void> eventDelete({
    required String id
  });
  Future<EventDetailModel> eventDetail({required String id});
  Future<void> eventStoreImage({
    required String eventId,
    required String path
  });
  Future<void> eventDeleteImage({
    required String eventId,
  });
}

class EventRemoteDataSourceImpl implements EventRemoteDataSource {

  Dio client;

  EventRemoteDataSourceImpl({required this.client});

  @override
  Future<EventModel> eventList() async {
    try { 
      final response = await client.get("${RemoteDataSourceConsts.baseUrl}/api/v1/event");
      Map<String, dynamic> data = response.data;
      EventModel eventModel = EventModel.fromJson(data);
      return eventModel;
    } on DioException catch (e) {
      String message = handleDioException(e);
      log(message);
      throw ServerException(message);
    } catch (e, stacktrace) {
      log(stacktrace.toString());
      throw Exception(e.toString());
    }
  }

  @override
  Future<EventDetailModel> eventDetail({
    required String id
  }) async {
    try {
      Response response = await client.get("${RemoteDataSourceConsts.baseUrl}/api/v1/event/detail/$id");
      Map<String, dynamic> data = response.data;
      EventDetailModel eventDetailModel = EventDetailModel.fromJson(data);
      return eventDetailModel;
    } on DioException catch (e) {
      String message = handleDioException(e);
      log(message);
      throw ServerException(message);
    } catch(e, stacktrace) {
      log(stacktrace.toString());
      throw Exception(e.toString());
    }
  }

  @override 
  Future<void> eventStore({
    required String id,
    required String title, required String caption, required String captionHtml,
    required String startDate, required String startTime, 
    required String endDate, required String endTime
  }) async {
    try { 
      await client.post("${RemoteDataSourceConsts.baseUrl}/api/v1/event/store",
        data: {
          "id": id, 
          "title": title, 
          "caption": caption,
          "caption_html": captionHtml,
          "start_date": startDate,
          "start_time": startTime,
          "end_date": endDate,
          "end_time": endTime
        }
      );
    } on DioException catch (e) {
      String message = handleDioException(e);
      log(message);
      throw ServerException(message);
    } catch (e, stacktrace) {
      log(stacktrace.toString());
      throw Exception(e.toString());
    }
  }

  @override 
  Future<void> eventUpdate({
    required String id,
    required String title, required String caption, required String captionHtml,
    required String startDate, required String startTime, 
    required String endDate, required String endTime
  }) async {
    try { 
      await client.put("${RemoteDataSourceConsts.baseUrl}/api/v1/event/update",
        data: {
          "id": id, 
          "title": title, 
          "caption": caption,
          "caption_html": captionHtml,
          "start_date": startDate,
          "start_time": startTime,
          "end_date": endDate,
          "end_time": endTime
        }
      );
    } on DioException catch (e) {
      String message = handleDioException(e);
      log(message);
      throw ServerException(message);
    } catch (e, stacktrace) {
      log(stacktrace.toString());
      throw Exception(e.toString());
    }
  }

  @override
  Future<void> eventStoreImage({
    required String eventId,
    required String path
  }) async {
    try {
      await client.post("${RemoteDataSourceConsts.baseUrl}/api/v1/event/store-image",
        data: {
          "event_id": eventId,
          "path": path
        }
      );
    } on DioException catch(e) {
      log(e.response!.data.toString());
      String message = handleDioException(e);
      log(message);
      throw ServerException(message);
    } catch(e, stacktrace) {
      log(stacktrace.toString());
      throw Exception(e.toString());
    }
  }

  @override
  Future<void> eventDelete({
    required String id 
  }) async {
    try {
      await client.delete("${RemoteDataSourceConsts.baseUrl}/api/v1/event/delete",
        data: {
          "id": id, 
        }
      );
    } on DioException catch(e) {
      String message = handleDioException(e);
      log(message);
      throw ServerException(message);
    } catch(e, stacktrace) {
      log(stacktrace.toString());
      throw Exception(e.toString());
    } 
  }

  @override
  Future<void> eventDeleteImage({
    required String eventId,
  }) async {
    try {
      await client.delete("${RemoteDataSourceConsts.baseUrl}/api/v1/event/delete-image",
        data: {
          "id": eventId,
        }
      );
    } on DioException catch(e) {
      log(e.response!.data.toString());
      String message = handleDioException(e);
      log(message);
      throw ServerException(message);
    } catch(e, stacktrace) {
      log(stacktrace.toString());
      throw Exception(e.toString());
    }
  }

  

}