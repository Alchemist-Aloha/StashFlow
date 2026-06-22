class Group {
  final String id;
  final String name;
  final String? date;
  final int? rating100;
  final String? director;
  final String? synopsis;
  final int? sceneCount;
  final int? subGroupCount;

  const Group({
    required this.id,
    required this.name,
    this.date,
    this.rating100,
    this.director,
    this.synopsis,
    this.sceneCount,
    this.subGroupCount,
  });

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      date: json['date']?.toString(),
      rating100: json['rating100'] as int?,
      director: json['director']?.toString(),
      synopsis: json['synopsis']?.toString(),
      sceneCount: json['scene_count'] as int?,
      subGroupCount: json['sub_group_count'] as int?,
    );
  }
}
