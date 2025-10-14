import 'dart:convert';

class LoginUserStatResponse {
  LoginUserStatResponse({
    this.code,
    this.message,
    this.ttl,
    this.data,
  });

  int? code;
  String? message;
  int? ttl;
  LoginUserStatData? data;

  factory LoginUserStatResponse.fromRawJson(String str) =>
      LoginUserStatResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory LoginUserStatResponse.fromJson(Map<String, dynamic> json) =>
      LoginUserStatResponse(
        code: json["code"],
        message: json["message"],
        ttl: json["ttl"],
        data: json["data"] == null ? null : LoginUserStatData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "message": message,
        "ttl": ttl,
        "data": data?.toJson(),
      };
}

class LoginUserStatData {
  LoginUserStatData({
    this.mid,
    this.following,
    this.whisper,
    this.black,
    this.follower,
    this.dynamicCount,
  });

  int? mid;
  int? following;
  int? whisper;
  int? black;
  int? follower;
  int? dynamicCount;

  factory LoginUserStatData.fromRawJson(String str) =>
      LoginUserStatData.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory LoginUserStatData.fromJson(Map<String, dynamic> json) =>
      LoginUserStatData(
        mid: json["mid"],
        following: json["following"],
        whisper: json["whisper"],
        black: json["black"],
        follower: json["follower"],
        dynamicCount: json["dynamic_count"],
      );

  Map<String, dynamic> toJson() => {
        "mid": mid,
        "following": following,
        "whisper": whisper,
        "black": black,
        "follower": follower,
        "dynamic_count": dynamicCount,
      };
}