class Scraper {
  final String id;
  final String name;
  final String? description;
  final List<String> types;

  Scraper({
    required this.id,
    required this.name,
    this.description,
    required this.types,
  });

  factory Scraper.fromJson(Map<String, dynamic> json) => Scraper(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String?,
        types: (json['types'] as List<dynamic>?)?.cast<String>() ?? [],
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'types': types,
      };
}
