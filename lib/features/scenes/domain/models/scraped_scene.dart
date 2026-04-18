class ScrapedPerformer {
  final String? storedId;
  final String? remoteSiteId;
  final String? name;
  final String? disambiguation;
  final String? gender;
  final String? birthdate;
  final String? ethnicity;
  final String? country;
  final String? eye_color;
  final String? height;
  final String? measurements;
  final String? fake_tits;
  final String? penis_length;
  final String? circumcised;
  final String? career_start;
  final String? career_end;
  final String? tattoos;
  final String? piercings;
  final String? aliases;
  final List<String> urls;
  final List<String> images;
  final String? image;
  final String? details;
  final String? death_date;
  final String? hair_color;
  final String? weight;
  final List<ScrapedTag> tags;

  ScrapedPerformer({
    this.storedId,
    this.remoteSiteId,
    this.name,
    this.disambiguation,
    this.gender,
    this.birthdate,
    this.ethnicity,
    this.country,
    this.eye_color,
    this.height,
    this.measurements,
    this.fake_tits,
    this.penis_length,
    this.circumcised,
    this.career_start,
    this.career_end,
    this.tattoos,
    this.piercings,
    this.aliases,
    List<String>? urls,
    List<String>? images,
    this.image,
    this.details,
    this.death_date,
    this.hair_color,
    this.weight,
    List<ScrapedTag>? tags,
  }) : urls = urls ?? [],
       images = images ?? [],
       tags = tags ?? [];

  factory ScrapedPerformer.fromJson(Map<String, dynamic> json) =>
      ScrapedPerformer(
        storedId: json['stored_id'] as String?,
        remoteSiteId: json['remote_site_id'] as String?,
        name: json['name'] as String?,
        disambiguation: json['disambiguation'] as String?,
        gender: json['gender'] as String?,
        birthdate: json['birthdate'] as String?,
        ethnicity: json['ethnicity'] as String?,
        country: json['country'] as String?,
        eye_color: json['eye_color'] as String?,
        height: json['height'] as String?,
        measurements: json['measurements'] as String?,
        fake_tits: json['fake_tits'] as String?,
        penis_length: json['penis_length'] as String?,
        circumcised: json['circumcised'] as String?,
        career_start: json['career_start'] as String?,
        career_end: json['career_end'] as String?,
        tattoos: json['tattoos'] as String?,
        piercings: json['piercings'] as String?,
        aliases: json['aliases'] as String?,
        urls: (json['urls'] as List<dynamic>?)?.cast<String>() ?? [],
        images: (json['images'] as List<dynamic>?)?.cast<String>() ?? [],
        image: json['image'] as String?,
        details: json['details'] as String?,
        death_date: json['death_date'] as String?,
        hair_color: json['hair_color'] as String?,
        weight: json['weight'] as String?,
        tags:
            (json['tags'] as List<dynamic>?)
                ?.map((e) => ScrapedTag.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );

  Map<String, dynamic> toJson() => {
    'stored_id': storedId,
    'remote_site_id': remoteSiteId,
    'name': name,
    'disambiguation': disambiguation,
    'gender': gender,
    'birthdate': birthdate,
    'ethnicity': ethnicity,
    'country': country,
    'eye_color': eye_color,
    'height': height,
    'measurements': measurements,
    'fake_tits': fake_tits,
    'penis_length': penis_length,
    'circumcised': circumcised,
    'career_start': career_start,
    'career_end': career_end,
    'tattoos': tattoos,
    'piercings': piercings,
    'aliases': aliases,
    'urls': urls,
    'images': images,
    'image': image,
    'details': details,
    'death_date': death_date,
    'hair_color': hair_color,
    'weight': weight,
    'tags': tags.map((t) => t.toJson()).toList(),
  };
}

class ScrapedStudio {
  final String? storedId;
  final String name;
  final String? remoteSiteId;
  final String? image;
  final String? url;
  final String? details;
  final List<String> urls;
  final ScrapedStudio? parent;
  final String? aliases;
  final List<ScrapedTag> tags;

  ScrapedStudio({
    this.storedId,
    required this.name,
    this.remoteSiteId,
    this.image,
    this.url,
    this.details,
    List<String>? urls,
    this.parent,
    this.aliases,
    List<ScrapedTag>? tags,
  }) : urls = urls ?? [],
       tags = tags ?? [];

  factory ScrapedStudio.fromJson(Map<String, dynamic> json) => ScrapedStudio(
    storedId: json['stored_id'] as String?,
    name: json['name'] as String,
    remoteSiteId: json['remote_site_id'] as String?,
    image: json['image'] as String?,
    url: json['url'] as String?,
    details: json['details'] as String?,
    urls: (json['urls'] as List<dynamic>?)?.cast<String>() ?? [],
    parent: json['parent'] != null
        ? ScrapedStudio.fromJson(json['parent'] as Map<String, dynamic>)
        : null,
    aliases: json['aliases'] as String?,
    tags:
        (json['tags'] as List<dynamic>?)
            ?.map((e) => ScrapedTag.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
  );

  Map<String, dynamic> toJson() => {
    'stored_id': storedId,
    'name': name,
    'remote_site_id': remoteSiteId,
    'image': image,
    'url': url,
    'details': details,
    'urls': urls,
    'parent': parent?.toJson(),
    'aliases': aliases,
    'tags': tags.map((t) => t.toJson()).toList(),
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
    studio: json['studio'] != null
        ? ScrapedStudio.fromJson(json['studio'] as Map<String, dynamic>)
        : null,
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
