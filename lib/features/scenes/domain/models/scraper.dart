class ScraperSpec {
  final List<String> urls;
  final List<String> supportedScrapes;

  ScraperSpec({required this.urls, required this.supportedScrapes});

  factory ScraperSpec.fromJson(Map<String, dynamic> json) => ScraperSpec(
    urls: (json['urls'] as List<dynamic>?)?.cast<String>() ?? [],
    supportedScrapes:
        (json['supported_scrapes'] as List<dynamic>?)?.cast<String>() ?? [],
  );

  Map<String, dynamic> toJson() => {
    'urls': urls,
    'supported_scrapes': supportedScrapes,
  };
}

class Scraper {
  final String id;
  final String name;
  final ScraperSpec? scene;
  final ScraperSpec? performer;
  final ScraperSpec? gallery;
  final ScraperSpec? image;

  Scraper({
    required this.id,
    required this.name,
    this.scene,
    this.performer,
    this.gallery,
    this.image,
  });

  factory Scraper.fromJson(Map<String, dynamic> json) => Scraper(
    id: json['id'] as String,
    name: json['name'] as String,
    scene:
        json['scene'] != null
            ? ScraperSpec.fromJson(json['scene'] as Map<String, dynamic>)
            : null,
    performer:
        json['performer'] != null
            ? ScraperSpec.fromJson(json['performer'] as Map<String, dynamic>)
            : null,
    gallery:
        json['gallery'] != null
            ? ScraperSpec.fromJson(json['gallery'] as Map<String, dynamic>)
            : null,
    image:
        json['image'] != null
            ? ScraperSpec.fromJson(json['image'] as Map<String, dynamic>)
            : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'scene': scene?.toJson(),
    'performer': performer?.toJson(),
    'gallery': gallery?.toJson(),
    'image': image?.toJson(),
  };
}
