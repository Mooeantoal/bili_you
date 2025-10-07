import 'dart:convert';

class UserSpaceStatResponse {
  UserSpaceStatResponse({
    this.code,
    this.message,
    this.ttl,
    this.data,
  });

  int? code;
  String? message;
  int? ttl;
  UserSpaceStatData? data;

  factory UserSpaceStatResponse.fromRawJson(String str) =>
      UserSpaceStatResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory UserSpaceStatResponse.fromJson(Map<String, dynamic> json) =>
      UserSpaceStatResponse(
        code: json["code"],
        message: json["message"],
        ttl: json["ttl"],
        data: json["data"] == null
            ? null
            : UserSpaceStatData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "message": message,
        "ttl": ttl,
        "data": data?.toJson(),
      };
}

class UserSpaceStatData {
  UserSpaceStatData({
    this.archive,
    this.article,
    this.likes,
  });

  Archive? archive;
  Article? article;
  Likes? likes;

  factory UserSpaceStatData.fromRawJson(String str) =>
      UserSpaceStatData.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory UserSpaceStatData.fromJson(Map<String, dynamic> json) =>
      UserSpaceStatData(
        archive: json["archive"] == null
            ? null
            : Archive.fromJson(json["archive"]),
        article:
            json["article"] == null ? null : Article.fromJson(json["article"]),
        likes: json["likes"] == null ? null : Likes.fromJson(json["likes"]),
      );

  Map<String, dynamic> toJson() => {
        "archive": archive?.toJson(),
        "article": article?.toJson(),
        "likes": likes?.toJson(),
      };
}

class Archive {
  Archive({
    this.view,
    this.pgcView,
  });

  dynamic view;
  int? pgcView;

  factory Archive.fromRawJson(String str) => Archive.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Archive.fromJson(Map<String, dynamic> json) => Archive(
        view: json["view"],
        pgcView: json["pgc_view"],
      );

  Map<String, dynamic> toJson() => {
        "view": view,
        "pgc_view": pgcView,
      };
}

class Article {
  Article({
    this.view,
  });

  int? view;

  factory Article.fromRawJson(String str) => Article.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Article.fromJson(Map<String, dynamic> json) => Article(
        view: json["view"],
      );

  Map<String, dynamic> toJson() => {
        "view": view,
      };
}

class Likes {
  Likes({
    this.likes,
  });

  int? likes;

  factory Likes.fromRawJson(String str) => Likes.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Likes.fromJson(Map<String, dynamic> json) => Likes(
        likes: json["likes"],
      );

  Map<String, dynamic> toJson() => {
        "likes": likes,
      };
}