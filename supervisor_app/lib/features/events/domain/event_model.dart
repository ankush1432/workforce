class EventModel {
  EventModel({
    required this.id,
    required this.title,
    this.description,
    this.location,
    required this.startDate,
    required this.endDate,
    this.bannerImage,
    this.bannerImageUrl,
    required this.status,
  });

  final int id;
  final String title;
  final String? description;
  final String? location;
  final String startDate;
  final String endDate;
  final String? bannerImage;
  final String? bannerImageUrl;
  final String status;

  factory EventModel.fromJson(Map<String, dynamic> json) => EventModel(
        id: json['id'] as int,
        title: json['title'] as String,
        description: json['description'] as String?,
        location: json['location'] as String?,
        startDate: json['start_date'] as String,
        endDate: json['end_date'] as String,
        bannerImage: json['banner_image'] as String?,
        bannerImageUrl: json['banner_image_url'] as String?,
        status: json['status'] as String? ?? 'draft',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'location': location,
        'start_date': startDate,
        'end_date': endDate,
        'banner_image': bannerImage,
        'banner_image_url': bannerImageUrl,
        'status': status,
      };
}
