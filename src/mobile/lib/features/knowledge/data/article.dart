import 'package:isar/isar.dart';

part 'article.g.dart';

@collection
class Article {
  Article();

  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String remoteId;

  late String title;
  late String category;
  late String content;
  String? imageUrl;
  late int version;
  late DateTime cachedAt;
  late int readTimeMinutes; // default 5
  late bool isFavorite; // local-only, never overwritten by remote sync

  factory Article.fromJson(Map<String, dynamic> json) => Article()
    ..remoteId = json['id'] as String
    ..title = json['title'] as String
    ..category = json['category'] as String
    ..content = json['content'] as String
    ..imageUrl = json['imageUrl'] as String?
    ..version = (json['version'] as int?) ?? 1
    ..cachedAt = DateTime.now()
    ..readTimeMinutes = (json['readTimeMinutes'] as int?) ?? 5
    ..isFavorite = false;
}
