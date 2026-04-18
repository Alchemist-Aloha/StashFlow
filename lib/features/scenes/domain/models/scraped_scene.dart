class ScrapedPerformer {
  final String? storedId;
  final String? remoteSiteId;
  final String? name;
  final List<String> urls;
  final List<String> images;

  ScrapedPerformer({
    this.storedId,
    this.remoteSiteId,
    this.name,
    List<String>? urls,
    List<String>? images,
  }) : urls = urls ?? [],
       images = images ?? [];

  factory ScrapedPerformer.fromJson(Map<String, dynamic> json) =>
      ScrapedPerformer(
        storedId: json['stored_id'] as String?,
        remoteSiteId: json['remote_site_id'] as String?,
        name: json['name'] as String?,
        urls: (json['urls'] as List<dynamic>?)?.cast<String>() ?? [],
        images: (json['images'] as List<dynamic>?)?.cast<String>() ?? [],
      );

  Map<String, dynamic> toJson() => {
    'stored_id': storedId,
    'remote_site_id': remoteSiteId,
    'name': name,
    'urls': urls,
    'images': images,
  };
}

class ScrapedStudio {
  final String? storedId;
  final String name;
  final String? remoteSiteId;
  final String? image;
  final String? url;

  ScrapedStudio({
    this.storedId,
    required this.name,
    this.remoteSiteId,
    this.image,
    this.url,
  });

  factory ScrapedStudio.fromJson(Map<String, dynamic> json) => ScrapedStudio(
        storedId: json['stored_id'] as String?,
        name: json['name'] as String,
        remoteSiteId: json['remote_site_id'] as String?,
        image: json['image'] as String?,
        url: json['url'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'stored_id': storedId,
        'name': name,
        'remote_site_id': remoteSiteId,
        'image': image,
        'url': url,
      };
}

class ScrapedTag {
  final String? storedId;
  final String name;

  ScrapedTag({this.storedId, required this.name});

  factory ScrapedTag.fromJson(Map<String, dynamic> json) => ScrapedTag(
    storedId: json['stored_id'] as String?,
    name: json['name'] as String,
  );

  Map<String, dynamic> toJson() => {'stored_id': storedId, 'name': name};
}

class ScrapedScene {
  final String? remoteSiteId;
  final String? title;
  final String? details;
  final List<String> urls;
  final DateTime? date;
  final List<ScrapedTag> tags;
  final List<ScrapedPerformer> performers;
  final String? image; // base64 encoded image data
  final String? studioId;
  final ScrapedStudio? studio;

  ScrapedScene({
    this.remoteSiteId,
    this.title,
    this.details,
    List<String>? urls,
    this.date,
    List<ScrapedTag>? tags,
    List<ScrapedPerformer>? performers,
    this.image,
    this.studioId,
    this.studio,
  }) : urls = urls ?? [],
       tags = tags ?? [],
       performers = performers ?? [];

  factory ScrapedScene.fromJson(Map<String, dynamic> json) => ScrapedScene(
    remoteSiteId: json['remote_site_id'] as String?,
    title: json['title'] as String?,
    details: json['details'] as String?,
    urls: (json['urls'] as List<dynamic>?)?.cast<String>() ?? [],
    date: json['date'] != null ? DateTime.tryParse(json['date']) : null,
    tags:
        (json['tags'] as List<dynamic>?)
            ?.map((e) => ScrapedTag.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
    performers:
        (json['performers'] as List<dynamic>?)
            ?.map((p) => ScrapedPerformer.fromJson(p as Map<String, dynamic>))
            .toList() ??
        [],
    image: json['image'] as String?,
    studioId: json['studio_id'] as String?,
    studio: json['studio'] != null ? ScrapedStudio.fromJson(json['studio'] as Map<String, dynamic>) : null,
  );

  Map<String, dynamic> toJson() => {
    'remote_site_id': remoteSiteId,
    'title': title,
    'details': details,
    'urls': urls,
    'date': date?.toIso8601String(),
    'tags': tags.map((t) => t.toJson()).toList(),
    'performers': performers.map((p) => p.toJson()).toList(),
    'image': image,
    'studio_id': studioId,
    'studio': studio?.toJson(),
  };
}
