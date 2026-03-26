class ScrapedPerformer {
  final String? id;
  final String? name;
  final String? url;
  final String? imageUrl;

  ScrapedPerformer({this.id, this.name, this.url, this.imageUrl});

  factory ScrapedPerformer.fromJson(Map<String, dynamic> json) =>
      ScrapedPerformer(
        id: json['id'] as String?,
        name: json['name'] as String?,
        url: json['url'] as String?,
        imageUrl: json['image_url'] as String?,
      );
}

class ScrapedScene {
  final String? id;
  final String? title;
  final String? details;
  final String? url;
  final DateTime? date;
  final List<String> tags;
  final List<ScrapedPerformer> performers;
  final String? imageUrl;

  ScrapedScene({
    this.id,
    this.title,
    this.details,
    this.url,
    this.date,
    List<String>? tags,
    List<ScrapedPerformer>? performers,
    this.imageUrl,
  })  : tags = tags ?? [],
        performers = performers ?? [];

  factory ScrapedScene.fromJson(Map<String, dynamic> json) => ScrapedScene(
        id: json['id'] as String?,
        title: json['title'] as String?,
        details: json['details'] as String?,
        url: json['url'] as String?,
        date: json['date'] != null ? DateTime.tryParse(json['date']) : null,
        tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
        performers: (json['performers'] as List<dynamic>?)
                ?.map((p) => ScrapedPerformer.fromJson(p as Map<String, dynamic>))
                .toList() ??
            [],
        imageUrl: json['image_url'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'details': details,
        'url': url,
        'date': date?.toIso8601String(),
        'tags': tags,
        'performers': performers
            .map((p) => {
                  'id': p.id,
                  'name': p.name,
                  'url': p.url,
                  'image_url': p.imageUrl,
                })
            .toList(),
        'image_url': imageUrl,
      };
}
