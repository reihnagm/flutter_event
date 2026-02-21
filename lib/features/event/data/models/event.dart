class EventResponse {
  final int status;
  final bool error;
  final String message;
  final EventPagination data;

  EventResponse({
    required this.status,
    required this.error,
    required this.message,
    required this.data,
  });

  factory EventResponse.fromJson(Map<String, dynamic> json) {
    return EventResponse(
      status: json["status"],
      error: json["error"],
      message: json["message"],
      data: EventPagination.fromJson(json["data"]),
    );
  }
}

class EventPagination {
  final int page;
  final int limit;
  final int total;
  final List<EventItem> events;

  EventPagination({
    required this.page,
    required this.limit,
    required this.total,
    required this.events,
  });

  factory EventPagination.fromJson(Map<String, dynamic> json) {
    return EventPagination(
      page: json["page"],
      limit: json["limit"],
      total: json["total"],
      events: List<EventItem>.from(json["data"].map((x) => EventItem.fromJson(x))),
    );
  }
}

class EventItem {
  final int id;
  final String uid;
  final String title;
  final String content;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final EventAuthor author;
  final List<EventImage> images;

  EventItem({
    required this.id,
    required this.uid,
    required this.title,
    required this.content,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
    required this.updatedAt,
    required this.author,
    required this.images,
  });

  factory EventItem.fromJson(Map<String, dynamic> json) {
    return EventItem(
      id: json["id"],
      uid: json["uid"],
      title: json["title"] ?? "",
      content: json["content"] ?? "",
      startDate: json["start_date"] != null ? DateTime.parse(json["start_date"]) : null,
      endDate: json["end_date"] != null ? DateTime.parse(json["end_date"]) : null,
      createdAt: json["created_at"] != null ? DateTime.parse(json["created_at"]) : null,
      updatedAt: json["updated_at"] != null ? DateTime.parse(json["updated_at"]) : null,
      author: EventAuthor.fromJson(json["author"]),
      images: List<EventImage>.from((json["images"] ?? []).map((x) => EventImage.fromJson(x))),
    );
  }
}

class EventAuthor {
  final String uid;
  final String email;
  final String phone;
  final String fullname;

  EventAuthor({
    required this.uid,
    required this.email,
    required this.phone,
    required this.fullname,
  });

  factory EventAuthor.fromJson(Map<String, dynamic> json) {
    return EventAuthor(
      uid: json["uid"] ?? "",
      email: json["email"] ?? "",
      phone: json["phone"] ?? "",
      fullname: json["fullname"] ?? "",
    );
  }
}

class EventImage {
  final int id;
  final String path;

  EventImage({required this.id, required this.path});

  factory EventImage.fromJson(Map<String, dynamic> json) {
    return EventImage(id: json["id"], path: json["path"] ?? "");
  }
}
