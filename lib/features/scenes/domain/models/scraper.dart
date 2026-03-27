class Scraper {
  final String id;
  final String name;
  final String? description;

  Scraper({
    required this.id,
    required this.name,
    this.description,
  });

  factory Scraper.fromJson(Map<String, dynamic> json) => Scraper(
        id: json['id'] as String,
        name: json['name'] as String,
        description: json['description'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
      };
}
