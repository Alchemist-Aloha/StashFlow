class Group {
  final String id;
  final String name;
  final String? date;
  final int? rating100;
  final String? director;
  final String? synopsis;
  final int? sceneCount;
  final int? subGroupCount;

  /// Cover images; Stash serves a placeholder URL containing `default=true`
  /// when none is set.
  final String? frontImagePath;
  final String? backImagePath;
  final String? aliases;

  /// Running time in seconds.
  final int? duration;
  final List<String> urls;
  final String? studioId;
  final String? studioName;
  final String? studioImagePath;
  final List<({String id, String name})> tags;
  final List<GroupRelation> containingGroups;
  final List<GroupRelation> subGroups;

  const Group({
    required this.id,
    required this.name,
    this.date,
    this.rating100,
    this.director,
    this.synopsis,
    this.sceneCount,
    this.subGroupCount,
    this.frontImagePath,
    this.backImagePath,
    this.aliases,
    this.duration,
    this.urls = const [],
    this.studioId,
    this.studioName,
    this.studioImagePath,
    this.tags = const [],
    this.containingGroups = const [],
    this.subGroups = const [],
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    final studio = json['studio'] as Map<String, dynamic>?;
    return Group(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      date: json['date']?.toString(),
      rating100: json['rating100'] as int?,
      director: json['director']?.toString(),
      synopsis: json['synopsis']?.toString(),
      sceneCount: json['scene_count'] as int?,
      subGroupCount: json['sub_group_count'] as int?,
      frontImagePath: json['front_image_path']?.toString(),
      backImagePath: json['back_image_path']?.toString(),
      aliases: json['aliases']?.toString(),
      duration: json['duration'] as int?,
      urls: [
        for (final url in json['urls'] as List<dynamic>? ?? const [])
          url.toString(),
      ],
      studioId: studio?['id']?.toString(),
      studioName: studio?['name']?.toString(),
      studioImagePath: studio?['image_path']?.toString(),
      tags: [
        for (final tag in json['tags'] as List<dynamic>? ?? const [])
          (
            id: (tag as Map<String, dynamic>)['id'].toString(),
            name: tag['name'].toString(),
          ),
      ],
      containingGroups: GroupRelation._listFromJson(json['containing_groups']),
      subGroups: GroupRelation._listFromJson(json['sub_groups']),
    );
  }
}

/// A group linked to another group, with the link's optional description
/// (for example "Volume one").
class GroupRelation {
  final String id;
  final String name;
  final String? imagePath;
  final String? description;

  const GroupRelation({
    required this.id,
    required this.name,
    this.imagePath,
    this.description,
  });

  static List<GroupRelation> _listFromJson(Object? raw) => [
    for (final entry in raw as List<dynamic>? ?? const [])
      if ((entry as Map<String, dynamic>)['group']
          case final Map<String, dynamic> group)
        GroupRelation(
          id: group['id'].toString(),
          name: group['name']?.toString() ?? '',
          imagePath: group['front_image_path']?.toString(),
          description: entry['description']?.toString(),
        ),
  ];
}
