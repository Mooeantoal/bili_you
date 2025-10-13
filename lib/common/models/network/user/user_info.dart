import 'dart:convert';

class UserInfoResponse {
  UserInfoResponse({
    this.code,
    this.message,
    this.ttl,
    this.data,
  });

  int? code;
  String? message;
  int? ttl;
  UserInfoData? data;

  factory UserInfoResponse.fromRawJson(String str) =>
      UserInfoResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory UserInfoResponse.fromJson(Map<String, dynamic> json) =>
      UserInfoResponse(
        code: json["code"],
        message: json["message"],
        ttl: json["ttl"],
        data: json["data"] == null ? null : UserInfoData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "message": message,
        "ttl": ttl,
        "data": data?.toJson(),
      };
}

class UserInfoData {
  UserInfoData({
    this.mid,
    this.name,
    this.sex,
    this.face,
    this.sign,
    this.rank,
    this.level,
    this.jointime,
    this.moral,
    this.silence,
    this.coins,
    this.fansBadge,
    this.likeNum,
    this.vip,
    this.official,
    this.nameplate,
    this.school,
    this.profession,
    this.tags,
    this.series,
    this.isSeniorMember,
  });

  int? mid;
  String? name;
  String? sex;
  String? face;
  String? sign;
  int? rank;
  int? level;
  int? jointime;
  int? moral;
  int? silence;
  int? coins;
  int? fansBadge;
  int? likeNum;
  Vip? vip;
  Official? official;
  Nameplate? nameplate;
  School? school;
  Profession? profession;
  List<dynamic>? tags;
  Series? series;
  int? isSeniorMember;

  factory UserInfoData.fromRawJson(String str) =>
      UserInfoData.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory UserInfoData.fromJson(Map<String, dynamic> json) => UserInfoData(
        mid: json["mid"],
        name: json["name"],
        sex: json["sex"],
        face: json["face"],
        sign: json["sign"],
        rank: json["rank"],
        level: json["level"],
        jointime: json["jointime"],
        moral: json["moral"],
        silence: json["silence"],
        coins: json["coins"],
        fansBadge: json["fans_badge"],
        likeNum: json["like_num"],
        vip: json["vip"] == null ? null : Vip.fromJson(json["vip"]),
        official:
            json["official"] == null ? null : Official.fromJson(json["official"]),
        nameplate: json["nameplate"] == null
            ? null
            : Nameplate.fromJson(json["nameplate"]),
        school:
            json["school"] == null ? null : School.fromJson(json["school"]),
        profession: json["profession"] == null
            ? null
            : Profession.fromJson(json["profession"]),
        tags: json["tags"],
        series:
            json["series"] == null ? null : Series.fromJson(json["series"]),
        isSeniorMember: json["is_senior_member"],
      );

  Map<String, dynamic> toJson() => {
        "mid": mid,
        "name": name,
        "sex": sex,
        "face": face,
        "sign": sign,
        "rank": rank,
        "level": level,
        "jointime": jointime,
        "moral": moral,
        "silence": silence,
        "coins": coins,
        "fans_badge": fansBadge,
        "like_num": likeNum,
        "vip": vip?.toJson(),
        "official": official?.toJson(),
        "nameplate": nameplate?.toJson(),
        "school": school?.toJson(),
        "profession": profession?.toJson(),
        "tags": tags,
        "series": series?.toJson(),
        "is_senior_member": isSeniorMember,
      };
}

class Nameplate {
  Nameplate({
    this.nid,
    this.name,
    this.image,
    this.imageSmall,
    this.level,
    this.condition,
  });

  int? nid;
  String? name;
  String? image;
  String? imageSmall;
  String? level;
  String? condition;

  factory Nameplate.fromRawJson(String str) =>
      Nameplate.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Nameplate.fromJson(Map<String, dynamic> json) => Nameplate(
        nid: json["nid"],
        name: json["name"],
        image: json["image"],
        imageSmall: json["image_small"],
        level: json["level"],
        condition: json["condition"],
      );

  Map<String, dynamic> toJson() => {
        "nid": nid,
        "name": name,
        "image": image,
        "image_small": imageSmall,
        "level": level,
        "condition": condition,
      };
}

class Official {
  Official({
    this.role,
    this.title,
    this.desc,
    this.type,
  });

  int? role;
  String? title;
  String? desc;
  int? type;

  factory Official.fromRawJson(String str) => Official.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Official.fromJson(Map<String, dynamic> json) => Official(
        role: json["role"],
        title: json["title"],
        desc: json["desc"],
        type: json["type"],
      );

  Map<String, dynamic> toJson() => {
        "role": role,
        "title": title,
        "desc": desc,
        "type": type,
      };
}

class Profession {
  Profession({
    this.name,
    this.department,
    this.title,
    this.isShow,
  });

  String? name;
  String? department;
  String? title;
  int? isShow;

  factory Profession.fromRawJson(String str) =>
      Profession.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Profession.fromJson(Map<String, dynamic> json) => Profession(
        name: json["name"],
        department: json["department"],
        title: json["title"],
        isShow: json["is_show"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "department": department,
        "title": title,
        "is_show": isShow,
      };
}

class School {
  School({
    this.name,
  });

  String? name;

  factory School.fromRawJson(String str) => School.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory School.fromJson(Map<String, dynamic> json) => School(
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
      };
}

class Series {
  Series({
    this.userUpgradeStatus,
    this.showUpgradeWindow,
  });

  int? userUpgradeStatus;
  bool? showUpgradeWindow;

  factory Series.fromRawJson(String str) => Series.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Series.fromJson(Map<String, dynamic> json) => Series(
        userUpgradeStatus: json["user_upgrade_status"],
        showUpgradeWindow: json["show_upgrade_window"],
      );

  Map<String, dynamic> toJson() => {
        "user_upgrade_status": userUpgradeStatus,
        "show_upgrade_window": showUpgradeWindow,
      };
}

class Vip {
  Vip({
    this.type,
    this.status,
    this.dueDate,
    this.vipPayType,
    this.themeType,
    this.label,
    this.avatarSubscript,
    this.nicknameColor,
    this.role,
    this.avatarSubscriptUrl,
    this.tvVipStatus,
    this.tvVipPayType,
    this.tvDueDate,
  });

  int? type;
  int? status;
  int? dueDate;
  int? vipPayType;
  int? themeType;
  Label? label;
  int? avatarSubscript;
  String? nicknameColor;
  int? role;
  String? avatarSubscriptUrl;
  int? tvVipStatus;
  int? tvVipPayType;
  int? tvDueDate;

  factory Vip.fromRawJson(String str) => Vip.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Vip.fromJson(Map<String, dynamic> json) => Vip(
        type: json["type"],
        status: json["status"],
        dueDate: json["due_date"],
        vipPayType: json["vip_pay_type"],
        themeType: json["theme_type"],
        label: json["label"] == null ? null : Label.fromJson(json["label"]),
        avatarSubscript: json["avatar_subscript"],
        nicknameColor: json["nickname_color"],
        role: json["role"],
        avatarSubscriptUrl: json["avatar_subscript_url"],
        tvVipStatus: json["tv_vip_status"],
        tvVipPayType: json["tv_vip_pay_type"],
        tvDueDate: json["tv_due_date"],
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "status": status,
        "due_date": dueDate,
        "vip_pay_type": vipPayType,
        "theme_type": themeType,
        "label": label?.toJson(),
        "avatar_subscript": avatarSubscript,
        "nickname_color": nicknameColor,
        "role": role,
        "avatar_subscript_url": avatarSubscriptUrl,
        "tv_vip_status": tvVipStatus,
        "tv_vip_pay_type": tvVipPayType,
        "tv_due_date": tvDueDate,
      };
}

class Label {
  Label({
    this.path,
    this.text,
    this.labelTheme,
    this.textColor,
    this.bgStyle,
    this.bgColor,
    this.borderColor,
  });

  String? path;
  String? text;
  String? labelTheme;
  String? textColor;
  int? bgStyle;
  String? bgColor;
  String? borderColor;

  factory Label.fromRawJson(String str) => Label.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Label.fromJson(Map<String, dynamic> json) => Label(
        path: json["path"],
        text: json["text"],
        labelTheme: json["label_theme"],
        textColor: json["text_color"],
        bgStyle: json["bg_style"],
        bgColor: json["bg_color"],
        borderColor: json["border_color"],
      );

  Map<String, dynamic> toJson() => {
        "path": path,
        "text": text,
        "label_theme": labelTheme,
        "text_color": textColor,
        "bg_style": bgStyle,
        "bg_color": bgColor,
        "border_color": borderColor,
      };
}