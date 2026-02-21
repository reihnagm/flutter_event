class EventDetailResponse {
  final int status;
  final bool error;
  final String message;
  final EventDetail data;

  EventDetailResponse({
    required this.status,
    required this.error,
    required this.message,
    required this.data,
  });

  factory EventDetailResponse.fromJson(Map<String, dynamic> json) {
    return EventDetailResponse(
      status: json['status'] ?? 0,
      error: json['error'] ?? false,
      message: json['message'] ?? '',
      data: EventDetail.fromJson(json['data'] ?? const {}),
    );
  }
}

class EventDetail {
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

  EventDetail({
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

  factory EventDetail.fromJson(Map<String, dynamic> json) {
    return EventDetail(
      id: json['id'] ?? 0,
      uid: json['uid'] ?? '',
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      startDate: json['start_date'] != null ? DateTime.tryParse(json['start_date']) : null,
      endDate: json['end_date'] != null ? DateTime.tryParse(json['end_date']) : null,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
      author: EventAuthor.fromJson(json['author'] ?? const {}),
      images: (json['images'] as List? ?? const [])
          .map((x) => EventImage.fromJson(x as Map<String, dynamic>))
          .toList(),
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
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      fullname: json['fullname'] ?? '',
    );
  }
}

class EventImage {
  final int id;
  final String path;

  EventImage({required this.id, required this.path});

  factory EventImage.fromJson(Map<String, dynamic> json) {
    return EventImage(id: json['id'] ?? 0, path: json['path'] ?? '');
  }
}
