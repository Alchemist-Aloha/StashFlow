import '../../../../core/data/graphql/schema.graphql.dart';
import 'dart:async';
import 'package:gql/ast.dart';
import 'package:graphql/client.dart' as graphql;

class Fragment$PerformerData {
  Fragment$PerformerData({
    required this.id,
    required this.name,
    this.disambiguation,
    this.url,
    this.urls,
    this.gender,
    this.birthdate,
    this.ethnicity,
    this.country,
    this.eye_color,
    this.height_cm,
    this.measurements,
    this.fake_tits,
    this.penis_length,
    this.circumcised,
    this.tattoos,
    this.piercings,
    required this.alias_list,
    required this.favorite,
    this.image_path,
    this.details,
    this.death_date,
    this.hair_color,
    this.weight,
    this.rating100,
    required this.scene_count,
    required this.image_count,
    required this.gallery_count,
    required this.group_count,
    required this.tags,
    this.$__typename = 'Performer',
  });

  factory Fragment$PerformerData.fromJson(Map<String, dynamic> json) {
    final l$id = json['id'];
    final l$name = json['name'];
    final l$disambiguation = json['disambiguation'];
    final l$url = json['url'];
    final l$urls = json['urls'];
    final l$gender = json['gender'];
    final l$birthdate = json['birthdate'];
    final l$ethnicity = json['ethnicity'];
    final l$country = json['country'];
    final l$eye_color = json['eye_color'];
    final l$height_cm = json['height_cm'];
    final l$measurements = json['measurements'];
    final l$fake_tits = json['fake_tits'];
    final l$penis_length = json['penis_length'];
    final l$circumcised = json['circumcised'];
    final l$tattoos = json['tattoos'];
    final l$piercings = json['piercings'];
    final l$alias_list = json['alias_list'];
    final l$favorite = json['favorite'];
    final l$image_path = json['image_path'];
    final l$details = json['details'];
    final l$death_date = json['death_date'];
    final l$hair_color = json['hair_color'];
    final l$weight = json['weight'];
    final l$rating100 = json['rating100'];
    final l$scene_count = json['scene_count'];
    final l$image_count = json['image_count'];
    final l$gallery_count = json['gallery_count'];
    final l$group_count = json['group_count'];
    final l$tags = json['tags'];
    final l$$__typename = json['__typename'];
    return Fragment$PerformerData(
      id: (l$id as String),
      name: (l$name as String),
      disambiguation: (l$disambiguation as String?),
      url: (l$url as String?),
      urls: (l$urls as List<dynamic>?)?.map((e) => (e as String)).toList(),
      gender: l$gender == null
          ? null
          : fromJson$Enum$GenderEnum((l$gender as String)),
      birthdate: (l$birthdate as String?),
      ethnicity: (l$ethnicity as String?),
      country: (l$country as String?),
      eye_color: (l$eye_color as String?),
      height_cm: (l$height_cm as int?),
      measurements: (l$measurements as String?),
      fake_tits: (l$fake_tits as String?),
      penis_length: (l$penis_length as num?)?.toDouble(),
      circumcised: l$circumcised == null
          ? null
          : fromJson$Enum$CircumcisedEnum((l$circumcised as String)),
      tattoos: (l$tattoos as String?),
      piercings: (l$piercings as String?),
      alias_list: (l$alias_list as List<dynamic>)
          .map((e) => (e as String))
          .toList(),
      favorite: (l$favorite as bool),
      image_path: (l$image_path as String?),
      details: (l$details as String?),
      death_date: (l$death_date as String?),
      hair_color: (l$hair_color as String?),
      weight: (l$weight as int?),
      rating100: (l$rating100 as int?),
      scene_count: (l$scene_count as int),
      image_count: (l$image_count as int),
      gallery_count: (l$gallery_count as int),
      group_count: (l$group_count as int),
      tags: (l$tags as List<dynamic>)
          .map(
            (e) => Fragment$PerformerData$tags.fromJson(
              (e as Map<String, dynamic>),
            ),
          )
          .toList(),
      $__typename: (l$$__typename as String),
    );
  }

  final String id;

  final String name;

  final String? disambiguation;

  @Deprecated('Use urls')
  final String? url;

  final List<String>? urls;

  final Enum$GenderEnum? gender;

  final String? birthdate;

  final String? ethnicity;

  final String? country;

  final String? eye_color;

  final int? height_cm;

  final String? measurements;

  final String? fake_tits;

  final double? penis_length;

  final Enum$CircumcisedEnum? circumcised;

  final String? tattoos;

  final String? piercings;

  final List<String> alias_list;

  final bool favorite;

  final String? image_path;

  final String? details;

  final String? death_date;

  final String? hair_color;

  final int? weight;

  final int? rating100;

  final int scene_count;

  final int image_count;

  final int gallery_count;

  final int group_count;

  final List<Fragment$PerformerData$tags> tags;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$id = id;
    _resultData['id'] = l$id;
    final l$name = name;
    _resultData['name'] = l$name;
    final l$disambiguation = disambiguation;
    _resultData['disambiguation'] = l$disambiguation;
    final l$url = url;
    _resultData['url'] = l$url;
    final l$urls = urls;
    _resultData['urls'] = l$urls?.map((e) => e).toList();
    final l$gender = gender;
    _resultData['gender'] = l$gender == null
        ? null
        : toJson$Enum$GenderEnum(l$gender);
    final l$birthdate = birthdate;
    _resultData['birthdate'] = l$birthdate;
    final l$ethnicity = ethnicity;
    _resultData['ethnicity'] = l$ethnicity;
    final l$country = country;
    _resultData['country'] = l$country;
    final l$eye_color = eye_color;
    _resultData['eye_color'] = l$eye_color;
    final l$height_cm = height_cm;
    _resultData['height_cm'] = l$height_cm;
    final l$measurements = measurements;
    _resultData['measurements'] = l$measurements;
    final l$fake_tits = fake_tits;
    _resultData['fake_tits'] = l$fake_tits;
    final l$penis_length = penis_length;
    _resultData['penis_length'] = l$penis_length;
    final l$circumcised = circumcised;
    _resultData['circumcised'] = l$circumcised == null
        ? null
        : toJson$Enum$CircumcisedEnum(l$circumcised);
    final l$tattoos = tattoos;
    _resultData['tattoos'] = l$tattoos;
    final l$piercings = piercings;
    _resultData['piercings'] = l$piercings;
    final l$alias_list = alias_list;
    _resultData['alias_list'] = l$alias_list.map((e) => e).toList();
    final l$favorite = favorite;
    _resultData['favorite'] = l$favorite;
    final l$image_path = image_path;
    _resultData['image_path'] = l$image_path;
    final l$details = details;
    _resultData['details'] = l$details;
    final l$death_date = death_date;
    _resultData['death_date'] = l$death_date;
    final l$hair_color = hair_color;
    _resultData['hair_color'] = l$hair_color;
    final l$weight = weight;
    _resultData['weight'] = l$weight;
    final l$rating100 = rating100;
    _resultData['rating100'] = l$rating100;
    final l$scene_count = scene_count;
    _resultData['scene_count'] = l$scene_count;
    final l$image_count = image_count;
    _resultData['image_count'] = l$image_count;
    final l$gallery_count = gallery_count;
    _resultData['gallery_count'] = l$gallery_count;
    final l$group_count = group_count;
    _resultData['group_count'] = l$group_count;
    final l$tags = tags;
    _resultData['tags'] = l$tags.map((e) => e.toJson()).toList();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$id = id;
    final l$name = name;
    final l$disambiguation = disambiguation;
    final l$url = url;
    final l$urls = urls;
    final l$gender = gender;
    final l$birthdate = birthdate;
    final l$ethnicity = ethnicity;
    final l$country = country;
    final l$eye_color = eye_color;
    final l$height_cm = height_cm;
    final l$measurements = measurements;
    final l$fake_tits = fake_tits;
    final l$penis_length = penis_length;
    final l$circumcised = circumcised;
    final l$tattoos = tattoos;
    final l$piercings = piercings;
    final l$alias_list = alias_list;
    final l$favorite = favorite;
    final l$image_path = image_path;
    final l$details = details;
    final l$death_date = death_date;
    final l$hair_color = hair_color;
    final l$weight = weight;
    final l$rating100 = rating100;
    final l$scene_count = scene_count;
    final l$image_count = image_count;
    final l$gallery_count = gallery_count;
    final l$group_count = group_count;
    final l$tags = tags;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$id,
      l$name,
      l$disambiguation,
      l$url,
      l$urls == null ? null : Object.hashAll(l$urls.map((v) => v)),
      l$gender,
      l$birthdate,
      l$ethnicity,
      l$country,
      l$eye_color,
      l$height_cm,
      l$measurements,
      l$fake_tits,
      l$penis_length,
      l$circumcised,
      l$tattoos,
      l$piercings,
      Object.hashAll(l$alias_list.map((v) => v)),
      l$favorite,
      l$image_path,
      l$details,
      l$death_date,
      l$hair_color,
      l$weight,
      l$rating100,
      l$scene_count,
      l$image_count,
      l$gallery_count,
      l$group_count,
      Object.hashAll(l$tags.map((v) => v)),
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$PerformerData || runtimeType != other.runtimeType) {
      return false;
    }
    final l$id = id;
    final lOther$id = other.id;
    if (l$id != lOther$id) {
      return false;
    }
    final l$name = name;
    final lOther$name = other.name;
    if (l$name != lOther$name) {
      return false;
    }
    final l$disambiguation = disambiguation;
    final lOther$disambiguation = other.disambiguation;
    if (l$disambiguation != lOther$disambiguation) {
      return false;
    }
    final l$url = url;
    final lOther$url = other.url;
    if (l$url != lOther$url) {
      return false;
    }
    final l$urls = urls;
    final lOther$urls = other.urls;
    if (l$urls != null && lOther$urls != null) {
      if (l$urls.length != lOther$urls.length) {
        return false;
      }
      for (int i = 0; i < l$urls.length; i++) {
        final l$urls$entry = l$urls[i];
        final lOther$urls$entry = lOther$urls[i];
        if (l$urls$entry != lOther$urls$entry) {
          return false;
        }
      }
    } else if (l$urls != lOther$urls) {
      return false;
    }
    final l$gender = gender;
    final lOther$gender = other.gender;
    if (l$gender != lOther$gender) {
      return false;
    }
    final l$birthdate = birthdate;
    final lOther$birthdate = other.birthdate;
    if (l$birthdate != lOther$birthdate) {
      return false;
    }
    final l$ethnicity = ethnicity;
    final lOther$ethnicity = other.ethnicity;
    if (l$ethnicity != lOther$ethnicity) {
      return false;
    }
    final l$country = country;
    final lOther$country = other.country;
    if (l$country != lOther$country) {
      return false;
    }
    final l$eye_color = eye_color;
    final lOther$eye_color = other.eye_color;
    if (l$eye_color != lOther$eye_color) {
      return false;
    }
    final l$height_cm = height_cm;
    final lOther$height_cm = other.height_cm;
    if (l$height_cm != lOther$height_cm) {
      return false;
    }
    final l$measurements = measurements;
    final lOther$measurements = other.measurements;
    if (l$measurements != lOther$measurements) {
      return false;
    }
    final l$fake_tits = fake_tits;
    final lOther$fake_tits = other.fake_tits;
    if (l$fake_tits != lOther$fake_tits) {
      return false;
    }
    final l$penis_length = penis_length;
    final lOther$penis_length = other.penis_length;
    if (l$penis_length != lOther$penis_length) {
      return false;
    }
    final l$circumcised = circumcised;
    final lOther$circumcised = other.circumcised;
    if (l$circumcised != lOther$circumcised) {
      return false;
    }
    final l$tattoos = tattoos;
    final lOther$tattoos = other.tattoos;
    if (l$tattoos != lOther$tattoos) {
      return false;
    }
    final l$piercings = piercings;
    final lOther$piercings = other.piercings;
    if (l$piercings != lOther$piercings) {
      return false;
    }
    final l$alias_list = alias_list;
    final lOther$alias_list = other.alias_list;
    if (l$alias_list.length != lOther$alias_list.length) {
      return false;
    }
    for (int i = 0; i < l$alias_list.length; i++) {
      final l$alias_list$entry = l$alias_list[i];
      final lOther$alias_list$entry = lOther$alias_list[i];
      if (l$alias_list$entry != lOther$alias_list$entry) {
        return false;
      }
    }
    final l$favorite = favorite;
    final lOther$favorite = other.favorite;
    if (l$favorite != lOther$favorite) {
      return false;
    }
    final l$image_path = image_path;
    final lOther$image_path = other.image_path;
    if (l$image_path != lOther$image_path) {
      return false;
    }
    final l$details = details;
    final lOther$details = other.details;
    if (l$details != lOther$details) {
      return false;
    }
    final l$death_date = death_date;
    final lOther$death_date = other.death_date;
    if (l$death_date != lOther$death_date) {
      return false;
    }
    final l$hair_color = hair_color;
    final lOther$hair_color = other.hair_color;
    if (l$hair_color != lOther$hair_color) {
      return false;
    }
    final l$weight = weight;
    final lOther$weight = other.weight;
    if (l$weight != lOther$weight) {
      return false;
    }
    final l$rating100 = rating100;
    final lOther$rating100 = other.rating100;
    if (l$rating100 != lOther$rating100) {
      return false;
    }
    final l$scene_count = scene_count;
    final lOther$scene_count = other.scene_count;
    if (l$scene_count != lOther$scene_count) {
      return false;
    }
    final l$image_count = image_count;
    final lOther$image_count = other.image_count;
    if (l$image_count != lOther$image_count) {
      return false;
    }
    final l$gallery_count = gallery_count;
    final lOther$gallery_count = other.gallery_count;
    if (l$gallery_count != lOther$gallery_count) {
      return false;
    }
    final l$group_count = group_count;
    final lOther$group_count = other.group_count;
    if (l$group_count != lOther$group_count) {
      return false;
    }
    final l$tags = tags;
    final lOther$tags = other.tags;
    if (l$tags.length != lOther$tags.length) {
      return false;
    }
    for (int i = 0; i < l$tags.length; i++) {
      final l$tags$entry = l$tags[i];
      final lOther$tags$entry = lOther$tags[i];
      if (l$tags$entry != lOther$tags$entry) {
        return false;
      }
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Fragment$PerformerData on Fragment$PerformerData {
  CopyWith$Fragment$PerformerData<Fragment$PerformerData> get copyWith =>
      CopyWith$Fragment$PerformerData(this, (i) => i);
}

abstract class CopyWith$Fragment$PerformerData<TRes> {
  factory CopyWith$Fragment$PerformerData(
    Fragment$PerformerData instance,
    TRes Function(Fragment$PerformerData) then,
  ) = _CopyWithImpl$Fragment$PerformerData;

  factory CopyWith$Fragment$PerformerData.stub(TRes res) =
      _CopyWithStubImpl$Fragment$PerformerData;

  TRes call({
    String? id,
    String? name,
    String? disambiguation,
    String? url,
    List<String>? urls,
    Enum$GenderEnum? gender,
    String? birthdate,
    String? ethnicity,
    String? country,
    String? eye_color,
    int? height_cm,
    String? measurements,
    String? fake_tits,
    double? penis_length,
    Enum$CircumcisedEnum? circumcised,
    String? tattoos,
    String? piercings,
    List<String>? alias_list,
    bool? favorite,
    String? image_path,
    String? details,
    String? death_date,
    String? hair_color,
    int? weight,
    int? rating100,
    int? scene_count,
    int? image_count,
    int? gallery_count,
    int? group_count,
    List<Fragment$PerformerData$tags>? tags,
    String? $__typename,
  });
  TRes tags(
    Iterable<Fragment$PerformerData$tags> Function(
      Iterable<
        CopyWith$Fragment$PerformerData$tags<Fragment$PerformerData$tags>
      >,
    )
    _fn,
  );
}

class _CopyWithImpl$Fragment$PerformerData<TRes>
    implements CopyWith$Fragment$PerformerData<TRes> {
  _CopyWithImpl$Fragment$PerformerData(this._instance, this._then);

  final Fragment$PerformerData _instance;

  final TRes Function(Fragment$PerformerData) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? id = _undefined,
    Object? name = _undefined,
    Object? disambiguation = _undefined,
    Object? url = _undefined,
    Object? urls = _undefined,
    Object? gender = _undefined,
    Object? birthdate = _undefined,
    Object? ethnicity = _undefined,
    Object? country = _undefined,
    Object? eye_color = _undefined,
    Object? height_cm = _undefined,
    Object? measurements = _undefined,
    Object? fake_tits = _undefined,
    Object? penis_length = _undefined,
    Object? circumcised = _undefined,
    Object? tattoos = _undefined,
    Object? piercings = _undefined,
    Object? alias_list = _undefined,
    Object? favorite = _undefined,
    Object? image_path = _undefined,
    Object? details = _undefined,
    Object? death_date = _undefined,
    Object? hair_color = _undefined,
    Object? weight = _undefined,
    Object? rating100 = _undefined,
    Object? scene_count = _undefined,
    Object? image_count = _undefined,
    Object? gallery_count = _undefined,
    Object? group_count = _undefined,
    Object? tags = _undefined,
    Object? $__typename = _undefined,
  }) => _then(
    Fragment$PerformerData(
      id: id == _undefined || id == null ? _instance.id : (id as String),
      name: name == _undefined || name == null
          ? _instance.name
          : (name as String),
      disambiguation: disambiguation == _undefined
          ? _instance.disambiguation
          : (disambiguation as String?),
      url: url == _undefined ? _instance.url : (url as String?),
      urls: urls == _undefined ? _instance.urls : (urls as List<String>?),
      gender: gender == _undefined
          ? _instance.gender
          : (gender as Enum$GenderEnum?),
      birthdate: birthdate == _undefined
          ? _instance.birthdate
          : (birthdate as String?),
      ethnicity: ethnicity == _undefined
          ? _instance.ethnicity
          : (ethnicity as String?),
      country: country == _undefined ? _instance.country : (country as String?),
      eye_color: eye_color == _undefined
          ? _instance.eye_color
          : (eye_color as String?),
      height_cm: height_cm == _undefined
          ? _instance.height_cm
          : (height_cm as int?),
      measurements: measurements == _undefined
          ? _instance.measurements
          : (measurements as String?),
      fake_tits: fake_tits == _undefined
          ? _instance.fake_tits
          : (fake_tits as String?),
      penis_length: penis_length == _undefined
          ? _instance.penis_length
          : (penis_length as double?),
      circumcised: circumcised == _undefined
          ? _instance.circumcised
          : (circumcised as Enum$CircumcisedEnum?),
      tattoos: tattoos == _undefined ? _instance.tattoos : (tattoos as String?),
      piercings: piercings == _undefined
          ? _instance.piercings
          : (piercings as String?),
      alias_list: alias_list == _undefined || alias_list == null
          ? _instance.alias_list
          : (alias_list as List<String>),
      favorite: favorite == _undefined || favorite == null
          ? _instance.favorite
          : (favorite as bool),
      image_path: image_path == _undefined
          ? _instance.image_path
          : (image_path as String?),
      details: details == _undefined ? _instance.details : (details as String?),
      death_date: death_date == _undefined
          ? _instance.death_date
          : (death_date as String?),
      hair_color: hair_color == _undefined
          ? _instance.hair_color
          : (hair_color as String?),
      weight: weight == _undefined ? _instance.weight : (weight as int?),
      rating100: rating100 == _undefined
          ? _instance.rating100
          : (rating100 as int?),
      scene_count: scene_count == _undefined || scene_count == null
          ? _instance.scene_count
          : (scene_count as int),
      image_count: image_count == _undefined || image_count == null
          ? _instance.image_count
          : (image_count as int),
      gallery_count: gallery_count == _undefined || gallery_count == null
          ? _instance.gallery_count
          : (gallery_count as int),
      group_count: group_count == _undefined || group_count == null
          ? _instance.group_count
          : (group_count as int),
      tags: tags == _undefined || tags == null
          ? _instance.tags
          : (tags as List<Fragment$PerformerData$tags>),
      $__typename: $__typename == _undefined || $__typename == null
          ? _instance.$__typename
          : ($__typename as String),
    ),
  );

  TRes tags(
    Iterable<Fragment$PerformerData$tags> Function(
      Iterable<
        CopyWith$Fragment$PerformerData$tags<Fragment$PerformerData$tags>
      >,
    )
    _fn,
  ) => call(
    tags: _fn(
      _instance.tags.map(
        (e) => CopyWith$Fragment$PerformerData$tags(e, (i) => i),
      ),
    ).toList(),
  );
}

class _CopyWithStubImpl$Fragment$PerformerData<TRes>
    implements CopyWith$Fragment$PerformerData<TRes> {
  _CopyWithStubImpl$Fragment$PerformerData(this._res);

  TRes _res;

  call({
    String? id,
    String? name,
    String? disambiguation,
    String? url,
    List<String>? urls,
    Enum$GenderEnum? gender,
    String? birthdate,
    String? ethnicity,
    String? country,
    String? eye_color,
    int? height_cm,
    String? measurements,
    String? fake_tits,
    double? penis_length,
    Enum$CircumcisedEnum? circumcised,
    String? tattoos,
    String? piercings,
    List<String>? alias_list,
    bool? favorite,
    String? image_path,
    String? details,
    String? death_date,
    String? hair_color,
    int? weight,
    int? rating100,
    int? scene_count,
    int? image_count,
    int? gallery_count,
    int? group_count,
    List<Fragment$PerformerData$tags>? tags,
    String? $__typename,
  }) => _res;

  tags(_fn) => _res;
}

const fragmentDefinitionPerformerData = FragmentDefinitionNode(
  name: NameNode(value: 'PerformerData'),
  typeCondition: TypeConditionNode(
    on: NamedTypeNode(name: NameNode(value: 'Performer'), isNonNull: false),
  ),
  directives: [],
  selectionSet: SelectionSetNode(
    selections: [
      FieldNode(
        name: NameNode(value: 'id'),
        alias: null,
        arguments: [],
        directives: [],
        selectionSet: null,
      ),
      FieldNode(
        name: NameNode(value: 'name'),
        alias: null,
        arguments: [],
        directives: [],
        selectionSet: null,
      ),
      FieldNode(
        name: NameNode(value: 'disambiguation'),
        alias: null,
        arguments: [],
        directives: [],
        selectionSet: null,
      ),
      FieldNode(
        name: NameNode(value: 'url'),
        alias: null,
        arguments: [],
        directives: [],
        selectionSet: null,
      ),
      FieldNode(
        name: NameNode(value: 'urls'),
        alias: null,
        arguments: [],
        directives: [],
        selectionSet: null,
      ),
      FieldNode(
        name: NameNode(value: 'gender'),
        alias: null,
        arguments: [],
        directives: [],
        selectionSet: null,
      ),
      FieldNode(
        name: NameNode(value: 'birthdate'),
        alias: null,
        arguments: [],
        directives: [],
        selectionSet: null,
      ),
      FieldNode(
        name: NameNode(value: 'ethnicity'),
        alias: null,
        arguments: [],
        directives: [],
        selectionSet: null,
      ),
      FieldNode(
        name: NameNode(value: 'country'),
        alias: null,
        arguments: [],
        directives: [],
        selectionSet: null,
      ),
      FieldNode(
        name: NameNode(value: 'eye_color'),
        alias: null,
        arguments: [],
        directives: [],
        selectionSet: null,
      ),
      FieldNode(
        name: NameNode(value: 'height_cm'),
        alias: null,
        arguments: [],
        directives: [],
        selectionSet: null,
      ),
      FieldNode(
        name: NameNode(value: 'measurements'),
        alias: null,
        arguments: [],
        directives: [],
        selectionSet: null,
      ),
      FieldNode(
        name: NameNode(value: 'fake_tits'),
        alias: null,
        arguments: [],
        directives: [],
        selectionSet: null,
      ),
      FieldNode(
        name: NameNode(value: 'penis_length'),
        alias: null,
        arguments: [],
        directives: [],
        selectionSet: null,
      ),
      FieldNode(
        name: NameNode(value: 'circumcised'),
        alias: null,
        arguments: [],
        directives: [],
        selectionSet: null,
      ),
      FieldNode(
        name: NameNode(value: 'tattoos'),
        alias: null,
        arguments: [],
        directives: [],
        selectionSet: null,
      ),
      FieldNode(
        name: NameNode(value: 'piercings'),
        alias: null,
        arguments: [],
        directives: [],
        selectionSet: null,
      ),
      FieldNode(
        name: NameNode(value: 'alias_list'),
        alias: null,
        arguments: [],
        directives: [],
        selectionSet: null,
      ),
      FieldNode(
        name: NameNode(value: 'favorite'),
        alias: null,
        arguments: [],
        directives: [],
        selectionSet: null,
      ),
      FieldNode(
        name: NameNode(value: 'image_path'),
        alias: null,
        arguments: [],
        directives: [],
        selectionSet: null,
      ),
      FieldNode(
        name: NameNode(value: 'details'),
        alias: null,
        arguments: [],
        directives: [],
        selectionSet: null,
      ),
      FieldNode(
        name: NameNode(value: 'death_date'),
        alias: null,
        arguments: [],
        directives: [],
        selectionSet: null,
      ),
      FieldNode(
        name: NameNode(value: 'hair_color'),
        alias: null,
        arguments: [],
        directives: [],
        selectionSet: null,
      ),
      FieldNode(
        name: NameNode(value: 'weight'),
        alias: null,
        arguments: [],
        directives: [],
        selectionSet: null,
      ),
      FieldNode(
        name: NameNode(value: 'rating100'),
        alias: null,
        arguments: [],
        directives: [],
        selectionSet: null,
      ),
      FieldNode(
        name: NameNode(value: 'scene_count'),
        alias: null,
        arguments: [],
        directives: [],
        selectionSet: null,
      ),
      FieldNode(
        name: NameNode(value: 'image_count'),
        alias: null,
        arguments: [],
        directives: [],
        selectionSet: null,
      ),
      FieldNode(
        name: NameNode(value: 'gallery_count'),
        alias: null,
        arguments: [],
        directives: [],
        selectionSet: null,
      ),
      FieldNode(
        name: NameNode(value: 'group_count'),
        alias: null,
        arguments: [],
        directives: [],
        selectionSet: null,
      ),
      FieldNode(
        name: NameNode(value: 'tags'),
        alias: null,
        arguments: [],
        directives: [],
        selectionSet: SelectionSetNode(
          selections: [
            FieldNode(
              name: NameNode(value: 'id'),
              alias: null,
              arguments: [],
              directives: [],
              selectionSet: null,
            ),
            FieldNode(
              name: NameNode(value: 'name'),
              alias: null,
              arguments: [],
              directives: [],
              selectionSet: null,
            ),
            FieldNode(
              name: NameNode(value: '__typename'),
              alias: null,
              arguments: [],
              directives: [],
              selectionSet: null,
            ),
          ],
        ),
      ),
      FieldNode(
        name: NameNode(value: '__typename'),
        alias: null,
        arguments: [],
        directives: [],
        selectionSet: null,
      ),
    ],
  ),
);
const documentNodeFragmentPerformerData = DocumentNode(
  definitions: [fragmentDefinitionPerformerData],
);

extension ClientExtension$Fragment$PerformerData on graphql.GraphQLClient {
  void writeFragment$PerformerData({
    required Fragment$PerformerData data,
    required Map<String, dynamic> idFields,
    bool broadcast = true,
  }) => this.writeFragment(
    graphql.FragmentRequest(
      idFields: idFields,
      fragment: const graphql.Fragment(
        fragmentName: 'PerformerData',
        document: documentNodeFragmentPerformerData,
      ),
    ),
    data: data.toJson(),
    broadcast: broadcast,
  );

  Fragment$PerformerData? readFragment$PerformerData({
    required Map<String, dynamic> idFields,
    bool optimistic = true,
  }) {
    final result = this.readFragment(
      graphql.FragmentRequest(
        idFields: idFields,
        fragment: const graphql.Fragment(
          fragmentName: 'PerformerData',
          document: documentNodeFragmentPerformerData,
        ),
      ),
      optimistic: optimistic,
    );
    return result == null ? null : Fragment$PerformerData.fromJson(result);
  }
}

class Fragment$PerformerData$tags {
  Fragment$PerformerData$tags({
    required this.id,
    required this.name,
    this.$__typename = 'Tag',
  });

  factory Fragment$PerformerData$tags.fromJson(Map<String, dynamic> json) {
    final l$id = json['id'];
    final l$name = json['name'];
    final l$$__typename = json['__typename'];
    return Fragment$PerformerData$tags(
      id: (l$id as String),
      name: (l$name as String),
      $__typename: (l$$__typename as String),
    );
  }

  final String id;

  final String name;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$id = id;
    _resultData['id'] = l$id;
    final l$name = name;
    _resultData['name'] = l$name;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$id = id;
    final l$name = name;
    final l$$__typename = $__typename;
    return Object.hashAll([l$id, l$name, l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Fragment$PerformerData$tags ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$id = id;
    final lOther$id = other.id;
    if (l$id != lOther$id) {
      return false;
    }
    final l$name = name;
    final lOther$name = other.name;
    if (l$name != lOther$name) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Fragment$PerformerData$tags
    on Fragment$PerformerData$tags {
  CopyWith$Fragment$PerformerData$tags<Fragment$PerformerData$tags>
  get copyWith => CopyWith$Fragment$PerformerData$tags(this, (i) => i);
}

abstract class CopyWith$Fragment$PerformerData$tags<TRes> {
  factory CopyWith$Fragment$PerformerData$tags(
    Fragment$PerformerData$tags instance,
    TRes Function(Fragment$PerformerData$tags) then,
  ) = _CopyWithImpl$Fragment$PerformerData$tags;

  factory CopyWith$Fragment$PerformerData$tags.stub(TRes res) =
      _CopyWithStubImpl$Fragment$PerformerData$tags;

  TRes call({String? id, String? name, String? $__typename});
}

class _CopyWithImpl$Fragment$PerformerData$tags<TRes>
    implements CopyWith$Fragment$PerformerData$tags<TRes> {
  _CopyWithImpl$Fragment$PerformerData$tags(this._instance, this._then);

  final Fragment$PerformerData$tags _instance;

  final TRes Function(Fragment$PerformerData$tags) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? id = _undefined,
    Object? name = _undefined,
    Object? $__typename = _undefined,
  }) => _then(
    Fragment$PerformerData$tags(
      id: id == _undefined || id == null ? _instance.id : (id as String),
      name: name == _undefined || name == null
          ? _instance.name
          : (name as String),
      $__typename: $__typename == _undefined || $__typename == null
          ? _instance.$__typename
          : ($__typename as String),
    ),
  );
}

class _CopyWithStubImpl$Fragment$PerformerData$tags<TRes>
    implements CopyWith$Fragment$PerformerData$tags<TRes> {
  _CopyWithStubImpl$Fragment$PerformerData$tags(this._res);

  TRes _res;

  call({String? id, String? name, String? $__typename}) => _res;
}

class Variables$Query$FindPerformers {
  factory Variables$Query$FindPerformers({
    Input$FindFilterType? filter,
    Input$PerformerFilterType? performer_filter,
  }) => Variables$Query$FindPerformers._({
    if (filter != null) r'filter': filter,
    if (performer_filter != null) r'performer_filter': performer_filter,
  });

  Variables$Query$FindPerformers._(this._$data);

  factory Variables$Query$FindPerformers.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    if (data.containsKey('filter')) {
      final l$filter = data['filter'];
      result$data['filter'] = l$filter == null
          ? null
          : Input$FindFilterType.fromJson((l$filter as Map<String, dynamic>));
    }
    if (data.containsKey('performer_filter')) {
      final l$performer_filter = data['performer_filter'];
      result$data['performer_filter'] = l$performer_filter == null
          ? null
          : Input$PerformerFilterType.fromJson(
              (l$performer_filter as Map<String, dynamic>),
            );
    }
    return Variables$Query$FindPerformers._(result$data);
  }

  Map<String, dynamic> _$data;

  Input$FindFilterType? get filter =>
      (_$data['filter'] as Input$FindFilterType?);

  Input$PerformerFilterType? get performer_filter =>
      (_$data['performer_filter'] as Input$PerformerFilterType?);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    if (_$data.containsKey('filter')) {
      final l$filter = filter;
      result$data['filter'] = l$filter?.toJson();
    }
    if (_$data.containsKey('performer_filter')) {
      final l$performer_filter = performer_filter;
      result$data['performer_filter'] = l$performer_filter?.toJson();
    }
    return result$data;
  }

  CopyWith$Variables$Query$FindPerformers<Variables$Query$FindPerformers>
  get copyWith => CopyWith$Variables$Query$FindPerformers(this, (i) => i);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Query$FindPerformers ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$filter = filter;
    final lOther$filter = other.filter;
    if (_$data.containsKey('filter') != other._$data.containsKey('filter')) {
      return false;
    }
    if (l$filter != lOther$filter) {
      return false;
    }
    final l$performer_filter = performer_filter;
    final lOther$performer_filter = other.performer_filter;
    if (_$data.containsKey('performer_filter') !=
        other._$data.containsKey('performer_filter')) {
      return false;
    }
    if (l$performer_filter != lOther$performer_filter) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$filter = filter;
    final l$performer_filter = performer_filter;
    return Object.hashAll([
      _$data.containsKey('filter') ? l$filter : const {},
      _$data.containsKey('performer_filter') ? l$performer_filter : const {},
    ]);
  }
}

abstract class CopyWith$Variables$Query$FindPerformers<TRes> {
  factory CopyWith$Variables$Query$FindPerformers(
    Variables$Query$FindPerformers instance,
    TRes Function(Variables$Query$FindPerformers) then,
  ) = _CopyWithImpl$Variables$Query$FindPerformers;

  factory CopyWith$Variables$Query$FindPerformers.stub(TRes res) =
      _CopyWithStubImpl$Variables$Query$FindPerformers;

  TRes call({
    Input$FindFilterType? filter,
    Input$PerformerFilterType? performer_filter,
  });
}

class _CopyWithImpl$Variables$Query$FindPerformers<TRes>
    implements CopyWith$Variables$Query$FindPerformers<TRes> {
  _CopyWithImpl$Variables$Query$FindPerformers(this._instance, this._then);

  final Variables$Query$FindPerformers _instance;

  final TRes Function(Variables$Query$FindPerformers) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? filter = _undefined,
    Object? performer_filter = _undefined,
  }) => _then(
    Variables$Query$FindPerformers._({
      ..._instance._$data,
      if (filter != _undefined) 'filter': (filter as Input$FindFilterType?),
      if (performer_filter != _undefined)
        'performer_filter': (performer_filter as Input$PerformerFilterType?),
    }),
  );
}

class _CopyWithStubImpl$Variables$Query$FindPerformers<TRes>
    implements CopyWith$Variables$Query$FindPerformers<TRes> {
  _CopyWithStubImpl$Variables$Query$FindPerformers(this._res);

  TRes _res;

  call({
    Input$FindFilterType? filter,
    Input$PerformerFilterType? performer_filter,
  }) => _res;
}

class Query$FindPerformers {
  Query$FindPerformers({
    required this.findPerformers,
    this.$__typename = 'Query',
  });

  factory Query$FindPerformers.fromJson(Map<String, dynamic> json) {
    final l$findPerformers = json['findPerformers'];
    final l$$__typename = json['__typename'];
    return Query$FindPerformers(
      findPerformers: Query$FindPerformers$findPerformers.fromJson(
        (l$findPerformers as Map<String, dynamic>),
      ),
      $__typename: (l$$__typename as String),
    );
  }

  final Query$FindPerformers$findPerformers findPerformers;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$findPerformers = findPerformers;
    _resultData['findPerformers'] = l$findPerformers.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$findPerformers = findPerformers;
    final l$$__typename = $__typename;
    return Object.hashAll([l$findPerformers, l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$FindPerformers || runtimeType != other.runtimeType) {
      return false;
    }
    final l$findPerformers = findPerformers;
    final lOther$findPerformers = other.findPerformers;
    if (l$findPerformers != lOther$findPerformers) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Query$FindPerformers on Query$FindPerformers {
  CopyWith$Query$FindPerformers<Query$FindPerformers> get copyWith =>
      CopyWith$Query$FindPerformers(this, (i) => i);
}

abstract class CopyWith$Query$FindPerformers<TRes> {
  factory CopyWith$Query$FindPerformers(
    Query$FindPerformers instance,
    TRes Function(Query$FindPerformers) then,
  ) = _CopyWithImpl$Query$FindPerformers;

  factory CopyWith$Query$FindPerformers.stub(TRes res) =
      _CopyWithStubImpl$Query$FindPerformers;

  TRes call({
    Query$FindPerformers$findPerformers? findPerformers,
    String? $__typename,
  });
  CopyWith$Query$FindPerformers$findPerformers<TRes> get findPerformers;
}

class _CopyWithImpl$Query$FindPerformers<TRes>
    implements CopyWith$Query$FindPerformers<TRes> {
  _CopyWithImpl$Query$FindPerformers(this._instance, this._then);

  final Query$FindPerformers _instance;

  final TRes Function(Query$FindPerformers) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? findPerformers = _undefined,
    Object? $__typename = _undefined,
  }) => _then(
    Query$FindPerformers(
      findPerformers: findPerformers == _undefined || findPerformers == null
          ? _instance.findPerformers
          : (findPerformers as Query$FindPerformers$findPerformers),
      $__typename: $__typename == _undefined || $__typename == null
          ? _instance.$__typename
          : ($__typename as String),
    ),
  );

  CopyWith$Query$FindPerformers$findPerformers<TRes> get findPerformers {
    final local$findPerformers = _instance.findPerformers;
    return CopyWith$Query$FindPerformers$findPerformers(
      local$findPerformers,
      (e) => call(findPerformers: e),
    );
  }
}

class _CopyWithStubImpl$Query$FindPerformers<TRes>
    implements CopyWith$Query$FindPerformers<TRes> {
  _CopyWithStubImpl$Query$FindPerformers(this._res);

  TRes _res;

  call({
    Query$FindPerformers$findPerformers? findPerformers,
    String? $__typename,
  }) => _res;

  CopyWith$Query$FindPerformers$findPerformers<TRes> get findPerformers =>
      CopyWith$Query$FindPerformers$findPerformers.stub(_res);
}

const documentNodeQueryFindPerformers = DocumentNode(
  definitions: [
    OperationDefinitionNode(
      type: OperationType.query,
      name: NameNode(value: 'FindPerformers'),
      variableDefinitions: [
        VariableDefinitionNode(
          variable: VariableNode(name: NameNode(value: 'filter')),
          type: NamedTypeNode(
            name: NameNode(value: 'FindFilterType'),
            isNonNull: false,
          ),
          defaultValue: DefaultValueNode(value: null),
          directives: [],
        ),
        VariableDefinitionNode(
          variable: VariableNode(name: NameNode(value: 'performer_filter')),
          type: NamedTypeNode(
            name: NameNode(value: 'PerformerFilterType'),
            isNonNull: false,
          ),
          defaultValue: DefaultValueNode(value: null),
          directives: [],
        ),
      ],
      directives: [],
      selectionSet: SelectionSetNode(
        selections: [
          FieldNode(
            name: NameNode(value: 'findPerformers'),
            alias: null,
            arguments: [
              ArgumentNode(
                name: NameNode(value: 'filter'),
                value: VariableNode(name: NameNode(value: 'filter')),
              ),
              ArgumentNode(
                name: NameNode(value: 'performer_filter'),
                value: VariableNode(name: NameNode(value: 'performer_filter')),
              ),
            ],
            directives: [],
            selectionSet: SelectionSetNode(
              selections: [
                FieldNode(
                  name: NameNode(value: 'count'),
                  alias: null,
                  arguments: [],
                  directives: [],
                  selectionSet: null,
                ),
                FieldNode(
                  name: NameNode(value: 'performers'),
                  alias: null,
                  arguments: [],
                  directives: [],
                  selectionSet: SelectionSetNode(
                    selections: [
                      FragmentSpreadNode(
                        name: NameNode(value: 'PerformerData'),
                        directives: [],
                      ),
                      FieldNode(
                        name: NameNode(value: '__typename'),
                        alias: null,
                        arguments: [],
                        directives: [],
                        selectionSet: null,
                      ),
                    ],
                  ),
                ),
                FieldNode(
                  name: NameNode(value: '__typename'),
                  alias: null,
                  arguments: [],
                  directives: [],
                  selectionSet: null,
                ),
              ],
            ),
          ),
          FieldNode(
            name: NameNode(value: '__typename'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: null,
          ),
        ],
      ),
    ),
    fragmentDefinitionPerformerData,
  ],
);
Query$FindPerformers _parserFn$Query$FindPerformers(
  Map<String, dynamic> data,
) => Query$FindPerformers.fromJson(data);
typedef OnQueryComplete$Query$FindPerformers =
    FutureOr<void> Function(Map<String, dynamic>?, Query$FindPerformers?);

class Options$Query$FindPerformers
    extends graphql.QueryOptions<Query$FindPerformers> {
  Options$Query$FindPerformers({
    String? operationName,
    Variables$Query$FindPerformers? variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$FindPerformers? typedOptimisticResult,
    Duration? pollInterval,
    graphql.Context? context,
    OnQueryComplete$Query$FindPerformers? onComplete,
    graphql.OnQueryError? onError,
  }) : onCompleteWithParsed = onComplete,
       super(
         variables: variables?.toJson() ?? {},
         operationName: operationName,
         fetchPolicy: fetchPolicy,
         errorPolicy: errorPolicy,
         cacheRereadPolicy: cacheRereadPolicy,
         optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
         pollInterval: pollInterval,
         context: context,
         onComplete: onComplete == null
             ? null
             : (data) => onComplete(
                 data,
                 data == null ? null : _parserFn$Query$FindPerformers(data),
               ),
         onError: onError,
         document: documentNodeQueryFindPerformers,
         parserFn: _parserFn$Query$FindPerformers,
       );

  final OnQueryComplete$Query$FindPerformers? onCompleteWithParsed;

  @override
  List<Object?> get properties => [
    ...super.onComplete == null
        ? super.properties
        : super.properties.where((property) => property != onComplete),
    onCompleteWithParsed,
  ];
}

class WatchOptions$Query$FindPerformers
    extends graphql.WatchQueryOptions<Query$FindPerformers> {
  WatchOptions$Query$FindPerformers({
    String? operationName,
    Variables$Query$FindPerformers? variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$FindPerformers? typedOptimisticResult,
    graphql.Context? context,
    Duration? pollInterval,
    bool? eagerlyFetchResults,
    bool carryForwardDataOnException = true,
    bool fetchResults = false,
  }) : super(
         variables: variables?.toJson() ?? {},
         operationName: operationName,
         fetchPolicy: fetchPolicy,
         errorPolicy: errorPolicy,
         cacheRereadPolicy: cacheRereadPolicy,
         optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
         context: context,
         document: documentNodeQueryFindPerformers,
         pollInterval: pollInterval,
         eagerlyFetchResults: eagerlyFetchResults,
         carryForwardDataOnException: carryForwardDataOnException,
         fetchResults: fetchResults,
         parserFn: _parserFn$Query$FindPerformers,
       );
}

class FetchMoreOptions$Query$FindPerformers extends graphql.FetchMoreOptions {
  FetchMoreOptions$Query$FindPerformers({
    required graphql.UpdateQuery updateQuery,
    Variables$Query$FindPerformers? variables,
  }) : super(
         updateQuery: updateQuery,
         variables: variables?.toJson() ?? {},
         document: documentNodeQueryFindPerformers,
       );
}

extension ClientExtension$Query$FindPerformers on graphql.GraphQLClient {
  Future<graphql.QueryResult<Query$FindPerformers>> query$FindPerformers([
    Options$Query$FindPerformers? options,
  ]) async => await this.query(options ?? Options$Query$FindPerformers());

  graphql.ObservableQuery<Query$FindPerformers> watchQuery$FindPerformers([
    WatchOptions$Query$FindPerformers? options,
  ]) => this.watchQuery(options ?? WatchOptions$Query$FindPerformers());

  void writeQuery$FindPerformers({
    required Query$FindPerformers data,
    Variables$Query$FindPerformers? variables,
    bool broadcast = true,
  }) => this.writeQuery(
    graphql.Request(
      operation: graphql.Operation(document: documentNodeQueryFindPerformers),
      variables: variables?.toJson() ?? const {},
    ),
    data: data.toJson(),
    broadcast: broadcast,
  );

  Query$FindPerformers? readQuery$FindPerformers({
    Variables$Query$FindPerformers? variables,
    bool optimistic = true,
  }) {
    final result = this.readQuery(
      graphql.Request(
        operation: graphql.Operation(document: documentNodeQueryFindPerformers),
        variables: variables?.toJson() ?? const {},
      ),
      optimistic: optimistic,
    );
    return result == null ? null : Query$FindPerformers.fromJson(result);
  }
}

class Query$FindPerformers$findPerformers {
  Query$FindPerformers$findPerformers({
    required this.count,
    required this.performers,
    this.$__typename = 'FindPerformersResultType',
  });

  factory Query$FindPerformers$findPerformers.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$count = json['count'];
    final l$performers = json['performers'];
    final l$$__typename = json['__typename'];
    return Query$FindPerformers$findPerformers(
      count: (l$count as int),
      performers: (l$performers as List<dynamic>)
          .map(
            (e) => Fragment$PerformerData.fromJson((e as Map<String, dynamic>)),
          )
          .toList(),
      $__typename: (l$$__typename as String),
    );
  }

  final int count;

  final List<Fragment$PerformerData> performers;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$count = count;
    _resultData['count'] = l$count;
    final l$performers = performers;
    _resultData['performers'] = l$performers.map((e) => e.toJson()).toList();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$count = count;
    final l$performers = performers;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$count,
      Object.hashAll(l$performers.map((v) => v)),
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$FindPerformers$findPerformers ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$count = count;
    final lOther$count = other.count;
    if (l$count != lOther$count) {
      return false;
    }
    final l$performers = performers;
    final lOther$performers = other.performers;
    if (l$performers.length != lOther$performers.length) {
      return false;
    }
    for (int i = 0; i < l$performers.length; i++) {
      final l$performers$entry = l$performers[i];
      final lOther$performers$entry = lOther$performers[i];
      if (l$performers$entry != lOther$performers$entry) {
        return false;
      }
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Query$FindPerformers$findPerformers
    on Query$FindPerformers$findPerformers {
  CopyWith$Query$FindPerformers$findPerformers<
    Query$FindPerformers$findPerformers
  >
  get copyWith => CopyWith$Query$FindPerformers$findPerformers(this, (i) => i);
}

abstract class CopyWith$Query$FindPerformers$findPerformers<TRes> {
  factory CopyWith$Query$FindPerformers$findPerformers(
    Query$FindPerformers$findPerformers instance,
    TRes Function(Query$FindPerformers$findPerformers) then,
  ) = _CopyWithImpl$Query$FindPerformers$findPerformers;

  factory CopyWith$Query$FindPerformers$findPerformers.stub(TRes res) =
      _CopyWithStubImpl$Query$FindPerformers$findPerformers;

  TRes call({
    int? count,
    List<Fragment$PerformerData>? performers,
    String? $__typename,
  });
  TRes performers(
    Iterable<Fragment$PerformerData> Function(
      Iterable<CopyWith$Fragment$PerformerData<Fragment$PerformerData>>,
    )
    _fn,
  );
}

class _CopyWithImpl$Query$FindPerformers$findPerformers<TRes>
    implements CopyWith$Query$FindPerformers$findPerformers<TRes> {
  _CopyWithImpl$Query$FindPerformers$findPerformers(this._instance, this._then);

  final Query$FindPerformers$findPerformers _instance;

  final TRes Function(Query$FindPerformers$findPerformers) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? count = _undefined,
    Object? performers = _undefined,
    Object? $__typename = _undefined,
  }) => _then(
    Query$FindPerformers$findPerformers(
      count: count == _undefined || count == null
          ? _instance.count
          : (count as int),
      performers: performers == _undefined || performers == null
          ? _instance.performers
          : (performers as List<Fragment$PerformerData>),
      $__typename: $__typename == _undefined || $__typename == null
          ? _instance.$__typename
          : ($__typename as String),
    ),
  );

  TRes performers(
    Iterable<Fragment$PerformerData> Function(
      Iterable<CopyWith$Fragment$PerformerData<Fragment$PerformerData>>,
    )
    _fn,
  ) => call(
    performers: _fn(
      _instance.performers.map(
        (e) => CopyWith$Fragment$PerformerData(e, (i) => i),
      ),
    ).toList(),
  );
}

class _CopyWithStubImpl$Query$FindPerformers$findPerformers<TRes>
    implements CopyWith$Query$FindPerformers$findPerformers<TRes> {
  _CopyWithStubImpl$Query$FindPerformers$findPerformers(this._res);

  TRes _res;

  call({
    int? count,
    List<Fragment$PerformerData>? performers,
    String? $__typename,
  }) => _res;

  performers(_fn) => _res;
}

class Variables$Query$FindPerformer {
  factory Variables$Query$FindPerformer({required String id}) =>
      Variables$Query$FindPerformer._({r'id': id});

  Variables$Query$FindPerformer._(this._$data);

  factory Variables$Query$FindPerformer.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$id = data['id'];
    result$data['id'] = (l$id as String);
    return Variables$Query$FindPerformer._(result$data);
  }

  Map<String, dynamic> _$data;

  String get id => (_$data['id'] as String);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$id = id;
    result$data['id'] = l$id;
    return result$data;
  }

  CopyWith$Variables$Query$FindPerformer<Variables$Query$FindPerformer>
  get copyWith => CopyWith$Variables$Query$FindPerformer(this, (i) => i);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Query$FindPerformer ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$id = id;
    final lOther$id = other.id;
    if (l$id != lOther$id) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$id = id;
    return Object.hashAll([l$id]);
  }
}

abstract class CopyWith$Variables$Query$FindPerformer<TRes> {
  factory CopyWith$Variables$Query$FindPerformer(
    Variables$Query$FindPerformer instance,
    TRes Function(Variables$Query$FindPerformer) then,
  ) = _CopyWithImpl$Variables$Query$FindPerformer;

  factory CopyWith$Variables$Query$FindPerformer.stub(TRes res) =
      _CopyWithStubImpl$Variables$Query$FindPerformer;

  TRes call({String? id});
}

class _CopyWithImpl$Variables$Query$FindPerformer<TRes>
    implements CopyWith$Variables$Query$FindPerformer<TRes> {
  _CopyWithImpl$Variables$Query$FindPerformer(this._instance, this._then);

  final Variables$Query$FindPerformer _instance;

  final TRes Function(Variables$Query$FindPerformer) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? id = _undefined}) => _then(
    Variables$Query$FindPerformer._({
      ..._instance._$data,
      if (id != _undefined && id != null) 'id': (id as String),
    }),
  );
}

class _CopyWithStubImpl$Variables$Query$FindPerformer<TRes>
    implements CopyWith$Variables$Query$FindPerformer<TRes> {
  _CopyWithStubImpl$Variables$Query$FindPerformer(this._res);

  TRes _res;

  call({String? id}) => _res;
}

class Query$FindPerformer {
  Query$FindPerformer({this.findPerformer, this.$__typename = 'Query'});

  factory Query$FindPerformer.fromJson(Map<String, dynamic> json) {
    final l$findPerformer = json['findPerformer'];
    final l$$__typename = json['__typename'];
    return Query$FindPerformer(
      findPerformer: l$findPerformer == null
          ? null
          : Fragment$PerformerData.fromJson(
              (l$findPerformer as Map<String, dynamic>),
            ),
      $__typename: (l$$__typename as String),
    );
  }

  final Fragment$PerformerData? findPerformer;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$findPerformer = findPerformer;
    _resultData['findPerformer'] = l$findPerformer?.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$findPerformer = findPerformer;
    final l$$__typename = $__typename;
    return Object.hashAll([l$findPerformer, l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Query$FindPerformer || runtimeType != other.runtimeType) {
      return false;
    }
    final l$findPerformer = findPerformer;
    final lOther$findPerformer = other.findPerformer;
    if (l$findPerformer != lOther$findPerformer) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Query$FindPerformer on Query$FindPerformer {
  CopyWith$Query$FindPerformer<Query$FindPerformer> get copyWith =>
      CopyWith$Query$FindPerformer(this, (i) => i);
}

abstract class CopyWith$Query$FindPerformer<TRes> {
  factory CopyWith$Query$FindPerformer(
    Query$FindPerformer instance,
    TRes Function(Query$FindPerformer) then,
  ) = _CopyWithImpl$Query$FindPerformer;

  factory CopyWith$Query$FindPerformer.stub(TRes res) =
      _CopyWithStubImpl$Query$FindPerformer;

  TRes call({Fragment$PerformerData? findPerformer, String? $__typename});
  CopyWith$Fragment$PerformerData<TRes> get findPerformer;
}

class _CopyWithImpl$Query$FindPerformer<TRes>
    implements CopyWith$Query$FindPerformer<TRes> {
  _CopyWithImpl$Query$FindPerformer(this._instance, this._then);

  final Query$FindPerformer _instance;

  final TRes Function(Query$FindPerformer) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? findPerformer = _undefined,
    Object? $__typename = _undefined,
  }) => _then(
    Query$FindPerformer(
      findPerformer: findPerformer == _undefined
          ? _instance.findPerformer
          : (findPerformer as Fragment$PerformerData?),
      $__typename: $__typename == _undefined || $__typename == null
          ? _instance.$__typename
          : ($__typename as String),
    ),
  );

  CopyWith$Fragment$PerformerData<TRes> get findPerformer {
    final local$findPerformer = _instance.findPerformer;
    return local$findPerformer == null
        ? CopyWith$Fragment$PerformerData.stub(_then(_instance))
        : CopyWith$Fragment$PerformerData(
            local$findPerformer,
            (e) => call(findPerformer: e),
          );
  }
}

class _CopyWithStubImpl$Query$FindPerformer<TRes>
    implements CopyWith$Query$FindPerformer<TRes> {
  _CopyWithStubImpl$Query$FindPerformer(this._res);

  TRes _res;

  call({Fragment$PerformerData? findPerformer, String? $__typename}) => _res;

  CopyWith$Fragment$PerformerData<TRes> get findPerformer =>
      CopyWith$Fragment$PerformerData.stub(_res);
}

const documentNodeQueryFindPerformer = DocumentNode(
  definitions: [
    OperationDefinitionNode(
      type: OperationType.query,
      name: NameNode(value: 'FindPerformer'),
      variableDefinitions: [
        VariableDefinitionNode(
          variable: VariableNode(name: NameNode(value: 'id')),
          type: NamedTypeNode(name: NameNode(value: 'ID'), isNonNull: true),
          defaultValue: DefaultValueNode(value: null),
          directives: [],
        ),
      ],
      directives: [],
      selectionSet: SelectionSetNode(
        selections: [
          FieldNode(
            name: NameNode(value: 'findPerformer'),
            alias: null,
            arguments: [
              ArgumentNode(
                name: NameNode(value: 'id'),
                value: VariableNode(name: NameNode(value: 'id')),
              ),
            ],
            directives: [],
            selectionSet: SelectionSetNode(
              selections: [
                FragmentSpreadNode(
                  name: NameNode(value: 'PerformerData'),
                  directives: [],
                ),
                FieldNode(
                  name: NameNode(value: '__typename'),
                  alias: null,
                  arguments: [],
                  directives: [],
                  selectionSet: null,
                ),
              ],
            ),
          ),
          FieldNode(
            name: NameNode(value: '__typename'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: null,
          ),
        ],
      ),
    ),
    fragmentDefinitionPerformerData,
  ],
);
Query$FindPerformer _parserFn$Query$FindPerformer(Map<String, dynamic> data) =>
    Query$FindPerformer.fromJson(data);
typedef OnQueryComplete$Query$FindPerformer =
    FutureOr<void> Function(Map<String, dynamic>?, Query$FindPerformer?);

class Options$Query$FindPerformer
    extends graphql.QueryOptions<Query$FindPerformer> {
  Options$Query$FindPerformer({
    String? operationName,
    required Variables$Query$FindPerformer variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$FindPerformer? typedOptimisticResult,
    Duration? pollInterval,
    graphql.Context? context,
    OnQueryComplete$Query$FindPerformer? onComplete,
    graphql.OnQueryError? onError,
  }) : onCompleteWithParsed = onComplete,
       super(
         variables: variables.toJson(),
         operationName: operationName,
         fetchPolicy: fetchPolicy,
         errorPolicy: errorPolicy,
         cacheRereadPolicy: cacheRereadPolicy,
         optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
         pollInterval: pollInterval,
         context: context,
         onComplete: onComplete == null
             ? null
             : (data) => onComplete(
                 data,
                 data == null ? null : _parserFn$Query$FindPerformer(data),
               ),
         onError: onError,
         document: documentNodeQueryFindPerformer,
         parserFn: _parserFn$Query$FindPerformer,
       );

  final OnQueryComplete$Query$FindPerformer? onCompleteWithParsed;

  @override
  List<Object?> get properties => [
    ...super.onComplete == null
        ? super.properties
        : super.properties.where((property) => property != onComplete),
    onCompleteWithParsed,
  ];
}

class WatchOptions$Query$FindPerformer
    extends graphql.WatchQueryOptions<Query$FindPerformer> {
  WatchOptions$Query$FindPerformer({
    String? operationName,
    required Variables$Query$FindPerformer variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$FindPerformer? typedOptimisticResult,
    graphql.Context? context,
    Duration? pollInterval,
    bool? eagerlyFetchResults,
    bool carryForwardDataOnException = true,
    bool fetchResults = false,
  }) : super(
         variables: variables.toJson(),
         operationName: operationName,
         fetchPolicy: fetchPolicy,
         errorPolicy: errorPolicy,
         cacheRereadPolicy: cacheRereadPolicy,
         optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
         context: context,
         document: documentNodeQueryFindPerformer,
         pollInterval: pollInterval,
         eagerlyFetchResults: eagerlyFetchResults,
         carryForwardDataOnException: carryForwardDataOnException,
         fetchResults: fetchResults,
         parserFn: _parserFn$Query$FindPerformer,
       );
}

class FetchMoreOptions$Query$FindPerformer extends graphql.FetchMoreOptions {
  FetchMoreOptions$Query$FindPerformer({
    required graphql.UpdateQuery updateQuery,
    required Variables$Query$FindPerformer variables,
  }) : super(
         updateQuery: updateQuery,
         variables: variables.toJson(),
         document: documentNodeQueryFindPerformer,
       );
}

extension ClientExtension$Query$FindPerformer on graphql.GraphQLClient {
  Future<graphql.QueryResult<Query$FindPerformer>> query$FindPerformer(
    Options$Query$FindPerformer options,
  ) async => await this.query(options);

  graphql.ObservableQuery<Query$FindPerformer> watchQuery$FindPerformer(
    WatchOptions$Query$FindPerformer options,
  ) => this.watchQuery(options);

  void writeQuery$FindPerformer({
    required Query$FindPerformer data,
    required Variables$Query$FindPerformer variables,
    bool broadcast = true,
  }) => this.writeQuery(
    graphql.Request(
      operation: graphql.Operation(document: documentNodeQueryFindPerformer),
      variables: variables.toJson(),
    ),
    data: data.toJson(),
    broadcast: broadcast,
  );

  Query$FindPerformer? readQuery$FindPerformer({
    required Variables$Query$FindPerformer variables,
    bool optimistic = true,
  }) {
    final result = this.readQuery(
      graphql.Request(
        operation: graphql.Operation(document: documentNodeQueryFindPerformer),
        variables: variables.toJson(),
      ),
      optimistic: optimistic,
    );
    return result == null ? null : Query$FindPerformer.fromJson(result);
  }
}

class Variables$Mutation$UpdatePerformerFavorite {
  factory Variables$Mutation$UpdatePerformerFavorite({
    required String id,
    required bool favorite,
  }) => Variables$Mutation$UpdatePerformerFavorite._({
    r'id': id,
    r'favorite': favorite,
  });

  Variables$Mutation$UpdatePerformerFavorite._(this._$data);

  factory Variables$Mutation$UpdatePerformerFavorite.fromJson(
    Map<String, dynamic> data,
  ) {
    final result$data = <String, dynamic>{};
    final l$id = data['id'];
    result$data['id'] = (l$id as String);
    final l$favorite = data['favorite'];
    result$data['favorite'] = (l$favorite as bool);
    return Variables$Mutation$UpdatePerformerFavorite._(result$data);
  }

  Map<String, dynamic> _$data;

  String get id => (_$data['id'] as String);

  bool get favorite => (_$data['favorite'] as bool);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$id = id;
    result$data['id'] = l$id;
    final l$favorite = favorite;
    result$data['favorite'] = l$favorite;
    return result$data;
  }

  CopyWith$Variables$Mutation$UpdatePerformerFavorite<
    Variables$Mutation$UpdatePerformerFavorite
  >
  get copyWith =>
      CopyWith$Variables$Mutation$UpdatePerformerFavorite(this, (i) => i);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Mutation$UpdatePerformerFavorite ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$id = id;
    final lOther$id = other.id;
    if (l$id != lOther$id) {
      return false;
    }
    final l$favorite = favorite;
    final lOther$favorite = other.favorite;
    if (l$favorite != lOther$favorite) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$id = id;
    final l$favorite = favorite;
    return Object.hashAll([l$id, l$favorite]);
  }
}

abstract class CopyWith$Variables$Mutation$UpdatePerformerFavorite<TRes> {
  factory CopyWith$Variables$Mutation$UpdatePerformerFavorite(
    Variables$Mutation$UpdatePerformerFavorite instance,
    TRes Function(Variables$Mutation$UpdatePerformerFavorite) then,
  ) = _CopyWithImpl$Variables$Mutation$UpdatePerformerFavorite;

  factory CopyWith$Variables$Mutation$UpdatePerformerFavorite.stub(TRes res) =
      _CopyWithStubImpl$Variables$Mutation$UpdatePerformerFavorite;

  TRes call({String? id, bool? favorite});
}

class _CopyWithImpl$Variables$Mutation$UpdatePerformerFavorite<TRes>
    implements CopyWith$Variables$Mutation$UpdatePerformerFavorite<TRes> {
  _CopyWithImpl$Variables$Mutation$UpdatePerformerFavorite(
    this._instance,
    this._then,
  );

  final Variables$Mutation$UpdatePerformerFavorite _instance;

  final TRes Function(Variables$Mutation$UpdatePerformerFavorite) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? id = _undefined, Object? favorite = _undefined}) => _then(
    Variables$Mutation$UpdatePerformerFavorite._({
      ..._instance._$data,
      if (id != _undefined && id != null) 'id': (id as String),
      if (favorite != _undefined && favorite != null)
        'favorite': (favorite as bool),
    }),
  );
}

class _CopyWithStubImpl$Variables$Mutation$UpdatePerformerFavorite<TRes>
    implements CopyWith$Variables$Mutation$UpdatePerformerFavorite<TRes> {
  _CopyWithStubImpl$Variables$Mutation$UpdatePerformerFavorite(this._res);

  TRes _res;

  call({String? id, bool? favorite}) => _res;
}

class Mutation$UpdatePerformerFavorite {
  Mutation$UpdatePerformerFavorite({
    this.performerUpdate,
    this.$__typename = 'Mutation',
  });

  factory Mutation$UpdatePerformerFavorite.fromJson(Map<String, dynamic> json) {
    final l$performerUpdate = json['performerUpdate'];
    final l$$__typename = json['__typename'];
    return Mutation$UpdatePerformerFavorite(
      performerUpdate: l$performerUpdate == null
          ? null
          : Mutation$UpdatePerformerFavorite$performerUpdate.fromJson(
              (l$performerUpdate as Map<String, dynamic>),
            ),
      $__typename: (l$$__typename as String),
    );
  }

  final Mutation$UpdatePerformerFavorite$performerUpdate? performerUpdate;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$performerUpdate = performerUpdate;
    _resultData['performerUpdate'] = l$performerUpdate?.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$performerUpdate = performerUpdate;
    final l$$__typename = $__typename;
    return Object.hashAll([l$performerUpdate, l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Mutation$UpdatePerformerFavorite ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$performerUpdate = performerUpdate;
    final lOther$performerUpdate = other.performerUpdate;
    if (l$performerUpdate != lOther$performerUpdate) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Mutation$UpdatePerformerFavorite
    on Mutation$UpdatePerformerFavorite {
  CopyWith$Mutation$UpdatePerformerFavorite<Mutation$UpdatePerformerFavorite>
  get copyWith => CopyWith$Mutation$UpdatePerformerFavorite(this, (i) => i);
}

abstract class CopyWith$Mutation$UpdatePerformerFavorite<TRes> {
  factory CopyWith$Mutation$UpdatePerformerFavorite(
    Mutation$UpdatePerformerFavorite instance,
    TRes Function(Mutation$UpdatePerformerFavorite) then,
  ) = _CopyWithImpl$Mutation$UpdatePerformerFavorite;

  factory CopyWith$Mutation$UpdatePerformerFavorite.stub(TRes res) =
      _CopyWithStubImpl$Mutation$UpdatePerformerFavorite;

  TRes call({
    Mutation$UpdatePerformerFavorite$performerUpdate? performerUpdate,
    String? $__typename,
  });
  CopyWith$Mutation$UpdatePerformerFavorite$performerUpdate<TRes>
  get performerUpdate;
}

class _CopyWithImpl$Mutation$UpdatePerformerFavorite<TRes>
    implements CopyWith$Mutation$UpdatePerformerFavorite<TRes> {
  _CopyWithImpl$Mutation$UpdatePerformerFavorite(this._instance, this._then);

  final Mutation$UpdatePerformerFavorite _instance;

  final TRes Function(Mutation$UpdatePerformerFavorite) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? performerUpdate = _undefined,
    Object? $__typename = _undefined,
  }) => _then(
    Mutation$UpdatePerformerFavorite(
      performerUpdate: performerUpdate == _undefined
          ? _instance.performerUpdate
          : (performerUpdate
                as Mutation$UpdatePerformerFavorite$performerUpdate?),
      $__typename: $__typename == _undefined || $__typename == null
          ? _instance.$__typename
          : ($__typename as String),
    ),
  );

  CopyWith$Mutation$UpdatePerformerFavorite$performerUpdate<TRes>
  get performerUpdate {
    final local$performerUpdate = _instance.performerUpdate;
    return local$performerUpdate == null
        ? CopyWith$Mutation$UpdatePerformerFavorite$performerUpdate.stub(
            _then(_instance),
          )
        : CopyWith$Mutation$UpdatePerformerFavorite$performerUpdate(
            local$performerUpdate,
            (e) => call(performerUpdate: e),
          );
  }
}

class _CopyWithStubImpl$Mutation$UpdatePerformerFavorite<TRes>
    implements CopyWith$Mutation$UpdatePerformerFavorite<TRes> {
  _CopyWithStubImpl$Mutation$UpdatePerformerFavorite(this._res);

  TRes _res;

  call({
    Mutation$UpdatePerformerFavorite$performerUpdate? performerUpdate,
    String? $__typename,
  }) => _res;

  CopyWith$Mutation$UpdatePerformerFavorite$performerUpdate<TRes>
  get performerUpdate =>
      CopyWith$Mutation$UpdatePerformerFavorite$performerUpdate.stub(_res);
}

const documentNodeMutationUpdatePerformerFavorite = DocumentNode(
  definitions: [
    OperationDefinitionNode(
      type: OperationType.mutation,
      name: NameNode(value: 'UpdatePerformerFavorite'),
      variableDefinitions: [
        VariableDefinitionNode(
          variable: VariableNode(name: NameNode(value: 'id')),
          type: NamedTypeNode(name: NameNode(value: 'ID'), isNonNull: true),
          defaultValue: DefaultValueNode(value: null),
          directives: [],
        ),
        VariableDefinitionNode(
          variable: VariableNode(name: NameNode(value: 'favorite')),
          type: NamedTypeNode(
            name: NameNode(value: 'Boolean'),
            isNonNull: true,
          ),
          defaultValue: DefaultValueNode(value: null),
          directives: [],
        ),
      ],
      directives: [],
      selectionSet: SelectionSetNode(
        selections: [
          FieldNode(
            name: NameNode(value: 'performerUpdate'),
            alias: null,
            arguments: [
              ArgumentNode(
                name: NameNode(value: 'input'),
                value: ObjectValueNode(
                  fields: [
                    ObjectFieldNode(
                      name: NameNode(value: 'id'),
                      value: VariableNode(name: NameNode(value: 'id')),
                    ),
                    ObjectFieldNode(
                      name: NameNode(value: 'favorite'),
                      value: VariableNode(name: NameNode(value: 'favorite')),
                    ),
                  ],
                ),
              ),
            ],
            directives: [],
            selectionSet: SelectionSetNode(
              selections: [
                FieldNode(
                  name: NameNode(value: 'id'),
                  alias: null,
                  arguments: [],
                  directives: [],
                  selectionSet: null,
                ),
                FieldNode(
                  name: NameNode(value: 'favorite'),
                  alias: null,
                  arguments: [],
                  directives: [],
                  selectionSet: null,
                ),
                FieldNode(
                  name: NameNode(value: '__typename'),
                  alias: null,
                  arguments: [],
                  directives: [],
                  selectionSet: null,
                ),
              ],
            ),
          ),
          FieldNode(
            name: NameNode(value: '__typename'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: null,
          ),
        ],
      ),
    ),
  ],
);
Mutation$UpdatePerformerFavorite _parserFn$Mutation$UpdatePerformerFavorite(
  Map<String, dynamic> data,
) => Mutation$UpdatePerformerFavorite.fromJson(data);
typedef OnMutationCompleted$Mutation$UpdatePerformerFavorite =
    FutureOr<void> Function(
      Map<String, dynamic>?,
      Mutation$UpdatePerformerFavorite?,
    );

class Options$Mutation$UpdatePerformerFavorite
    extends graphql.MutationOptions<Mutation$UpdatePerformerFavorite> {
  Options$Mutation$UpdatePerformerFavorite({
    String? operationName,
    required Variables$Mutation$UpdatePerformerFavorite variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdatePerformerFavorite? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$UpdatePerformerFavorite? onCompleted,
    graphql.OnMutationUpdate<Mutation$UpdatePerformerFavorite>? update,
    graphql.OnError? onError,
  }) : onCompletedWithParsed = onCompleted,
       super(
         variables: variables.toJson(),
         operationName: operationName,
         fetchPolicy: fetchPolicy,
         errorPolicy: errorPolicy,
         cacheRereadPolicy: cacheRereadPolicy,
         optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
         context: context,
         onCompleted: onCompleted == null
             ? null
             : (data) => onCompleted(
                 data,
                 data == null
                     ? null
                     : _parserFn$Mutation$UpdatePerformerFavorite(data),
               ),
         update: update,
         onError: onError,
         document: documentNodeMutationUpdatePerformerFavorite,
         parserFn: _parserFn$Mutation$UpdatePerformerFavorite,
       );

  final OnMutationCompleted$Mutation$UpdatePerformerFavorite?
  onCompletedWithParsed;

  @override
  List<Object?> get properties => [
    ...super.onCompleted == null
        ? super.properties
        : super.properties.where((property) => property != onCompleted),
    onCompletedWithParsed,
  ];
}

class WatchOptions$Mutation$UpdatePerformerFavorite
    extends graphql.WatchQueryOptions<Mutation$UpdatePerformerFavorite> {
  WatchOptions$Mutation$UpdatePerformerFavorite({
    String? operationName,
    required Variables$Mutation$UpdatePerformerFavorite variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdatePerformerFavorite? typedOptimisticResult,
    graphql.Context? context,
    Duration? pollInterval,
    bool? eagerlyFetchResults,
    bool carryForwardDataOnException = true,
    bool fetchResults = false,
  }) : super(
         variables: variables.toJson(),
         operationName: operationName,
         fetchPolicy: fetchPolicy,
         errorPolicy: errorPolicy,
         cacheRereadPolicy: cacheRereadPolicy,
         optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
         context: context,
         document: documentNodeMutationUpdatePerformerFavorite,
         pollInterval: pollInterval,
         eagerlyFetchResults: eagerlyFetchResults,
         carryForwardDataOnException: carryForwardDataOnException,
         fetchResults: fetchResults,
         parserFn: _parserFn$Mutation$UpdatePerformerFavorite,
       );
}

extension ClientExtension$Mutation$UpdatePerformerFavorite
    on graphql.GraphQLClient {
  Future<graphql.QueryResult<Mutation$UpdatePerformerFavorite>>
  mutate$UpdatePerformerFavorite(
    Options$Mutation$UpdatePerformerFavorite options,
  ) async => await this.mutate(options);

  graphql.ObservableQuery<Mutation$UpdatePerformerFavorite>
  watchMutation$UpdatePerformerFavorite(
    WatchOptions$Mutation$UpdatePerformerFavorite options,
  ) => this.watchMutation(options);
}

class Mutation$UpdatePerformerFavorite$performerUpdate {
  Mutation$UpdatePerformerFavorite$performerUpdate({
    required this.id,
    required this.favorite,
    this.$__typename = 'Performer',
  });

  factory Mutation$UpdatePerformerFavorite$performerUpdate.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$id = json['id'];
    final l$favorite = json['favorite'];
    final l$$__typename = json['__typename'];
    return Mutation$UpdatePerformerFavorite$performerUpdate(
      id: (l$id as String),
      favorite: (l$favorite as bool),
      $__typename: (l$$__typename as String),
    );
  }

  final String id;

  final bool favorite;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$id = id;
    _resultData['id'] = l$id;
    final l$favorite = favorite;
    _resultData['favorite'] = l$favorite;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$id = id;
    final l$favorite = favorite;
    final l$$__typename = $__typename;
    return Object.hashAll([l$id, l$favorite, l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Mutation$UpdatePerformerFavorite$performerUpdate ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$id = id;
    final lOther$id = other.id;
    if (l$id != lOther$id) {
      return false;
    }
    final l$favorite = favorite;
    final lOther$favorite = other.favorite;
    if (l$favorite != lOther$favorite) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Mutation$UpdatePerformerFavorite$performerUpdate
    on Mutation$UpdatePerformerFavorite$performerUpdate {
  CopyWith$Mutation$UpdatePerformerFavorite$performerUpdate<
    Mutation$UpdatePerformerFavorite$performerUpdate
  >
  get copyWith =>
      CopyWith$Mutation$UpdatePerformerFavorite$performerUpdate(this, (i) => i);
}

abstract class CopyWith$Mutation$UpdatePerformerFavorite$performerUpdate<TRes> {
  factory CopyWith$Mutation$UpdatePerformerFavorite$performerUpdate(
    Mutation$UpdatePerformerFavorite$performerUpdate instance,
    TRes Function(Mutation$UpdatePerformerFavorite$performerUpdate) then,
  ) = _CopyWithImpl$Mutation$UpdatePerformerFavorite$performerUpdate;

  factory CopyWith$Mutation$UpdatePerformerFavorite$performerUpdate.stub(
    TRes res,
  ) = _CopyWithStubImpl$Mutation$UpdatePerformerFavorite$performerUpdate;

  TRes call({String? id, bool? favorite, String? $__typename});
}

class _CopyWithImpl$Mutation$UpdatePerformerFavorite$performerUpdate<TRes>
    implements CopyWith$Mutation$UpdatePerformerFavorite$performerUpdate<TRes> {
  _CopyWithImpl$Mutation$UpdatePerformerFavorite$performerUpdate(
    this._instance,
    this._then,
  );

  final Mutation$UpdatePerformerFavorite$performerUpdate _instance;

  final TRes Function(Mutation$UpdatePerformerFavorite$performerUpdate) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? id = _undefined,
    Object? favorite = _undefined,
    Object? $__typename = _undefined,
  }) => _then(
    Mutation$UpdatePerformerFavorite$performerUpdate(
      id: id == _undefined || id == null ? _instance.id : (id as String),
      favorite: favorite == _undefined || favorite == null
          ? _instance.favorite
          : (favorite as bool),
      $__typename: $__typename == _undefined || $__typename == null
          ? _instance.$__typename
          : ($__typename as String),
    ),
  );
}

class _CopyWithStubImpl$Mutation$UpdatePerformerFavorite$performerUpdate<TRes>
    implements CopyWith$Mutation$UpdatePerformerFavorite$performerUpdate<TRes> {
  _CopyWithStubImpl$Mutation$UpdatePerformerFavorite$performerUpdate(this._res);

  TRes _res;

  call({String? id, bool? favorite, String? $__typename}) => _res;
}

class Variables$Mutation$CreatePerformer {
  factory Variables$Mutation$CreatePerformer({
    required Input$PerformerCreateInput input,
  }) => Variables$Mutation$CreatePerformer._({r'input': input});

  Variables$Mutation$CreatePerformer._(this._$data);

  factory Variables$Mutation$CreatePerformer.fromJson(
    Map<String, dynamic> data,
  ) {
    final result$data = <String, dynamic>{};
    final l$input = data['input'];
    result$data['input'] = Input$PerformerCreateInput.fromJson(
      (l$input as Map<String, dynamic>),
    );
    return Variables$Mutation$CreatePerformer._(result$data);
  }

  Map<String, dynamic> _$data;

  Input$PerformerCreateInput get input =>
      (_$data['input'] as Input$PerformerCreateInput);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$input = input;
    result$data['input'] = l$input.toJson();
    return result$data;
  }

  CopyWith$Variables$Mutation$CreatePerformer<
    Variables$Mutation$CreatePerformer
  >
  get copyWith => CopyWith$Variables$Mutation$CreatePerformer(this, (i) => i);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Variables$Mutation$CreatePerformer ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$input = input;
    final lOther$input = other.input;
    if (l$input != lOther$input) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$input = input;
    return Object.hashAll([l$input]);
  }
}

abstract class CopyWith$Variables$Mutation$CreatePerformer<TRes> {
  factory CopyWith$Variables$Mutation$CreatePerformer(
    Variables$Mutation$CreatePerformer instance,
    TRes Function(Variables$Mutation$CreatePerformer) then,
  ) = _CopyWithImpl$Variables$Mutation$CreatePerformer;

  factory CopyWith$Variables$Mutation$CreatePerformer.stub(TRes res) =
      _CopyWithStubImpl$Variables$Mutation$CreatePerformer;

  TRes call({Input$PerformerCreateInput? input});
}

class _CopyWithImpl$Variables$Mutation$CreatePerformer<TRes>
    implements CopyWith$Variables$Mutation$CreatePerformer<TRes> {
  _CopyWithImpl$Variables$Mutation$CreatePerformer(this._instance, this._then);

  final Variables$Mutation$CreatePerformer _instance;

  final TRes Function(Variables$Mutation$CreatePerformer) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? input = _undefined}) => _then(
    Variables$Mutation$CreatePerformer._({
      ..._instance._$data,
      if (input != _undefined && input != null)
        'input': (input as Input$PerformerCreateInput),
    }),
  );
}

class _CopyWithStubImpl$Variables$Mutation$CreatePerformer<TRes>
    implements CopyWith$Variables$Mutation$CreatePerformer<TRes> {
  _CopyWithStubImpl$Variables$Mutation$CreatePerformer(this._res);

  TRes _res;

  call({Input$PerformerCreateInput? input}) => _res;
}

class Mutation$CreatePerformer {
  Mutation$CreatePerformer({
    this.performerCreate,
    this.$__typename = 'Mutation',
  });

  factory Mutation$CreatePerformer.fromJson(Map<String, dynamic> json) {
    final l$performerCreate = json['performerCreate'];
    final l$$__typename = json['__typename'];
    return Mutation$CreatePerformer(
      performerCreate: l$performerCreate == null
          ? null
          : Mutation$CreatePerformer$performerCreate.fromJson(
              (l$performerCreate as Map<String, dynamic>),
            ),
      $__typename: (l$$__typename as String),
    );
  }

  final Mutation$CreatePerformer$performerCreate? performerCreate;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$performerCreate = performerCreate;
    _resultData['performerCreate'] = l$performerCreate?.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$performerCreate = performerCreate;
    final l$$__typename = $__typename;
    return Object.hashAll([l$performerCreate, l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Mutation$CreatePerformer ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$performerCreate = performerCreate;
    final lOther$performerCreate = other.performerCreate;
    if (l$performerCreate != lOther$performerCreate) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Mutation$CreatePerformer
    on Mutation$CreatePerformer {
  CopyWith$Mutation$CreatePerformer<Mutation$CreatePerformer> get copyWith =>
      CopyWith$Mutation$CreatePerformer(this, (i) => i);
}

abstract class CopyWith$Mutation$CreatePerformer<TRes> {
  factory CopyWith$Mutation$CreatePerformer(
    Mutation$CreatePerformer instance,
    TRes Function(Mutation$CreatePerformer) then,
  ) = _CopyWithImpl$Mutation$CreatePerformer;

  factory CopyWith$Mutation$CreatePerformer.stub(TRes res) =
      _CopyWithStubImpl$Mutation$CreatePerformer;

  TRes call({
    Mutation$CreatePerformer$performerCreate? performerCreate,
    String? $__typename,
  });
  CopyWith$Mutation$CreatePerformer$performerCreate<TRes> get performerCreate;
}

class _CopyWithImpl$Mutation$CreatePerformer<TRes>
    implements CopyWith$Mutation$CreatePerformer<TRes> {
  _CopyWithImpl$Mutation$CreatePerformer(this._instance, this._then);

  final Mutation$CreatePerformer _instance;

  final TRes Function(Mutation$CreatePerformer) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? performerCreate = _undefined,
    Object? $__typename = _undefined,
  }) => _then(
    Mutation$CreatePerformer(
      performerCreate: performerCreate == _undefined
          ? _instance.performerCreate
          : (performerCreate as Mutation$CreatePerformer$performerCreate?),
      $__typename: $__typename == _undefined || $__typename == null
          ? _instance.$__typename
          : ($__typename as String),
    ),
  );

  CopyWith$Mutation$CreatePerformer$performerCreate<TRes> get performerCreate {
    final local$performerCreate = _instance.performerCreate;
    return local$performerCreate == null
        ? CopyWith$Mutation$CreatePerformer$performerCreate.stub(
            _then(_instance),
          )
        : CopyWith$Mutation$CreatePerformer$performerCreate(
            local$performerCreate,
            (e) => call(performerCreate: e),
          );
  }
}

class _CopyWithStubImpl$Mutation$CreatePerformer<TRes>
    implements CopyWith$Mutation$CreatePerformer<TRes> {
  _CopyWithStubImpl$Mutation$CreatePerformer(this._res);

  TRes _res;

  call({
    Mutation$CreatePerformer$performerCreate? performerCreate,
    String? $__typename,
  }) => _res;

  CopyWith$Mutation$CreatePerformer$performerCreate<TRes> get performerCreate =>
      CopyWith$Mutation$CreatePerformer$performerCreate.stub(_res);
}

const documentNodeMutationCreatePerformer = DocumentNode(
  definitions: [
    OperationDefinitionNode(
      type: OperationType.mutation,
      name: NameNode(value: 'CreatePerformer'),
      variableDefinitions: [
        VariableDefinitionNode(
          variable: VariableNode(name: NameNode(value: 'input')),
          type: NamedTypeNode(
            name: NameNode(value: 'PerformerCreateInput'),
            isNonNull: true,
          ),
          defaultValue: DefaultValueNode(value: null),
          directives: [],
        ),
      ],
      directives: [],
      selectionSet: SelectionSetNode(
        selections: [
          FieldNode(
            name: NameNode(value: 'performerCreate'),
            alias: null,
            arguments: [
              ArgumentNode(
                name: NameNode(value: 'input'),
                value: VariableNode(name: NameNode(value: 'input')),
              ),
            ],
            directives: [],
            selectionSet: SelectionSetNode(
              selections: [
                FieldNode(
                  name: NameNode(value: 'id'),
                  alias: null,
                  arguments: [],
                  directives: [],
                  selectionSet: null,
                ),
                FieldNode(
                  name: NameNode(value: '__typename'),
                  alias: null,
                  arguments: [],
                  directives: [],
                  selectionSet: null,
                ),
              ],
            ),
          ),
          FieldNode(
            name: NameNode(value: '__typename'),
            alias: null,
            arguments: [],
            directives: [],
            selectionSet: null,
          ),
        ],
      ),
    ),
  ],
);
Mutation$CreatePerformer _parserFn$Mutation$CreatePerformer(
  Map<String, dynamic> data,
) => Mutation$CreatePerformer.fromJson(data);
typedef OnMutationCompleted$Mutation$CreatePerformer =
    FutureOr<void> Function(Map<String, dynamic>?, Mutation$CreatePerformer?);

class Options$Mutation$CreatePerformer
    extends graphql.MutationOptions<Mutation$CreatePerformer> {
  Options$Mutation$CreatePerformer({
    String? operationName,
    required Variables$Mutation$CreatePerformer variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$CreatePerformer? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$CreatePerformer? onCompleted,
    graphql.OnMutationUpdate<Mutation$CreatePerformer>? update,
    graphql.OnError? onError,
  }) : onCompletedWithParsed = onCompleted,
       super(
         variables: variables.toJson(),
         operationName: operationName,
         fetchPolicy: fetchPolicy,
         errorPolicy: errorPolicy,
         cacheRereadPolicy: cacheRereadPolicy,
         optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
         context: context,
         onCompleted: onCompleted == null
             ? null
             : (data) => onCompleted(
                 data,
                 data == null ? null : _parserFn$Mutation$CreatePerformer(data),
               ),
         update: update,
         onError: onError,
         document: documentNodeMutationCreatePerformer,
         parserFn: _parserFn$Mutation$CreatePerformer,
       );

  final OnMutationCompleted$Mutation$CreatePerformer? onCompletedWithParsed;

  @override
  List<Object?> get properties => [
    ...super.onCompleted == null
        ? super.properties
        : super.properties.where((property) => property != onCompleted),
    onCompletedWithParsed,
  ];
}

class WatchOptions$Mutation$CreatePerformer
    extends graphql.WatchQueryOptions<Mutation$CreatePerformer> {
  WatchOptions$Mutation$CreatePerformer({
    String? operationName,
    required Variables$Mutation$CreatePerformer variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$CreatePerformer? typedOptimisticResult,
    graphql.Context? context,
    Duration? pollInterval,
    bool? eagerlyFetchResults,
    bool carryForwardDataOnException = true,
    bool fetchResults = false,
  }) : super(
         variables: variables.toJson(),
         operationName: operationName,
         fetchPolicy: fetchPolicy,
         errorPolicy: errorPolicy,
         cacheRereadPolicy: cacheRereadPolicy,
         optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
         context: context,
         document: documentNodeMutationCreatePerformer,
         pollInterval: pollInterval,
         eagerlyFetchResults: eagerlyFetchResults,
         carryForwardDataOnException: carryForwardDataOnException,
         fetchResults: fetchResults,
         parserFn: _parserFn$Mutation$CreatePerformer,
       );
}

extension ClientExtension$Mutation$CreatePerformer on graphql.GraphQLClient {
  Future<graphql.QueryResult<Mutation$CreatePerformer>> mutate$CreatePerformer(
    Options$Mutation$CreatePerformer options,
  ) async => await this.mutate(options);

  graphql.ObservableQuery<Mutation$CreatePerformer>
  watchMutation$CreatePerformer(
    WatchOptions$Mutation$CreatePerformer options,
  ) => this.watchMutation(options);
}

class Mutation$CreatePerformer$performerCreate {
  Mutation$CreatePerformer$performerCreate({
    required this.id,
    this.$__typename = 'Performer',
  });

  factory Mutation$CreatePerformer$performerCreate.fromJson(
    Map<String, dynamic> json,
  ) {
    final l$id = json['id'];
    final l$$__typename = json['__typename'];
    return Mutation$CreatePerformer$performerCreate(
      id: (l$id as String),
      $__typename: (l$$__typename as String),
    );
  }

  final String id;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$id = id;
    _resultData['id'] = l$id;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$id = id;
    final l$$__typename = $__typename;
    return Object.hashAll([l$id, l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! Mutation$CreatePerformer$performerCreate ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$id = id;
    final lOther$id = other.id;
    if (l$id != lOther$id) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Mutation$CreatePerformer$performerCreate
    on Mutation$CreatePerformer$performerCreate {
  CopyWith$Mutation$CreatePerformer$performerCreate<
    Mutation$CreatePerformer$performerCreate
  >
  get copyWith =>
      CopyWith$Mutation$CreatePerformer$performerCreate(this, (i) => i);
}

abstract class CopyWith$Mutation$CreatePerformer$performerCreate<TRes> {
  factory CopyWith$Mutation$CreatePerformer$performerCreate(
    Mutation$CreatePerformer$performerCreate instance,
    TRes Function(Mutation$CreatePerformer$performerCreate) then,
  ) = _CopyWithImpl$Mutation$CreatePerformer$performerCreate;

  factory CopyWith$Mutation$CreatePerformer$performerCreate.stub(TRes res) =
      _CopyWithStubImpl$Mutation$CreatePerformer$performerCreate;

  TRes call({String? id, String? $__typename});
}

class _CopyWithImpl$Mutation$CreatePerformer$performerCreate<TRes>
    implements CopyWith$Mutation$CreatePerformer$performerCreate<TRes> {
  _CopyWithImpl$Mutation$CreatePerformer$performerCreate(
    this._instance,
    this._then,
  );

  final Mutation$CreatePerformer$performerCreate _instance;

  final TRes Function(Mutation$CreatePerformer$performerCreate) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? id = _undefined, Object? $__typename = _undefined}) =>
      _then(
        Mutation$CreatePerformer$performerCreate(
          id: id == _undefined || id == null ? _instance.id : (id as String),
          $__typename: $__typename == _undefined || $__typename == null
              ? _instance.$__typename
              : ($__typename as String),
        ),
      );
}

class _CopyWithStubImpl$Mutation$CreatePerformer$performerCreate<TRes>
    implements CopyWith$Mutation$CreatePerformer$performerCreate<TRes> {
  _CopyWithStubImpl$Mutation$CreatePerformer$performerCreate(this._res);

  TRes _res;

  call({String? id, String? $__typename}) => _res;
}
