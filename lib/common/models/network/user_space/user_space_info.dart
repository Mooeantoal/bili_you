import 'dart:convert';

class UserSpaceInfoResponse {
  UserSpaceInfoResponse({
    this.code,
    this.message,
    this.ttl,
    this.data,
  });

  int? code;
  String? message;
  int? ttl;
  UserSpaceInfoData? data;

  factory UserSpaceInfoResponse.fromRawJson(String str) =>
      UserSpaceInfoResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory UserSpaceInfoResponse.fromJson(Map<String, dynamic> json) =>
      UserSpaceInfoResponse(
        code: json["code"],
        message: json["message"],
        ttl: json["ttl"],
        data: json["data"] == null
            ? null
            : UserSpaceInfoData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "message": message,
        "ttl": ttl,
        "data": data?.toJson(),
      };
}

class UserSpaceInfoData {
  UserSpaceInfoData({
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
    this.birthday,
    this.coins,
    this.fansBadge,
    this.official,
    this.vip,
    this.pendant,
    this.nameplate,
    this.sysNotice,
    this.liveRoom,
    this.birthdayShow,
    this.isSeniorMember,
    this.honours,
    this.series,
    this.spaceTheme,
    this.themePreview,
    this.decorations,
    this.decoration,
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
  String? birthday;
  double? coins;
  bool? fansBadge;
  Official? official;
  Vip? vip;
  Pendant? pendant;
  Nameplate? nameplate;
  dynamic sysNotice;
  LiveRoom? liveRoom;
  dynamic birthdayShow;
  int? isSeniorMember;
  Honours? honours;
  Series? series;
  SpaceTheme? spaceTheme;
  dynamic themePreview;
  dynamic decorations;
  Decoration? decoration;

  factory UserSpaceInfoData.fromRawJson(String str) =>
      UserSpaceInfoData.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory UserSpaceInfoData.fromJson(Map<String, dynamic> json) =>
      UserSpaceInfoData(
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
        birthday: json["birthday"],
        coins: json["coins"]?.toDouble(),
        fansBadge: json["fans_badge"],
        official: json["official"] == null
            ? null
            : Official.fromJson(json["official"]),
        vip: json["vip"] == null ? null : Vip.fromJson(json["vip"]),
        pendant:
            json["pendant"] == null ? null : Pendant.fromJson(json["pendant"]),
        nameplate: json["nameplate"] == null
            ? null
            : Nameplate.fromJson(json["nameplate"]),
        sysNotice: json["sys_notice"],
        liveRoom: json["live_room"] == null
            ? null
            : LiveRoom.fromJson(json["live_room"]),
        birthdayShow: json["birthday_show"],
        isSeniorMember: json["is_senior_member"],
        honours:
            json["honours"] == null ? null : Honours.fromJson(json["honours"]),
        series: json["series"] == null ? null : Series.fromJson(json["series"]),
        spaceTheme: json["space_theme"] == null
            ? null
            : SpaceTheme.fromJson(json["space_theme"]),
        themePreview: json["theme_preview"],
        decorations: json["decorations"],
        decoration: json["decoration"] == null
            ? null
            : Decoration.fromJson(json["decoration"]),
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
        "birthday": birthday,
        "coins": coins,
        "fans_badge": fansBadge,
        "official": official?.toJson(),
        "vip": vip?.toJson(),
        "pendant": pendant?.toJson(),
        "nameplate": nameplate?.toJson(),
        "sys_notice": sysNotice,
        "live_room": liveRoom?.toJson(),
        "birthday_show": birthdayShow,
        "is_senior_member": isSeniorMember,
        "honours": honours?.toJson(),
        "series": series?.toJson(),
        "space_theme": spaceTheme?.toJson(),
        "theme_preview": themePreview,
        "decorations": decorations,
        "decoration": decoration?.toJson(),
      };
}

class Decoration {
  Decoration({
    this.id,
    this.cardUrl,
    this.jumpingUrl,
    this.fan,
    this.idStr,
  });

  int? id;
  String? cardUrl;
  String? jumpingUrl;
  Fan? fan;
  String? idStr;

  factory Decoration.fromRawJson(String str) =>
      Decoration.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Decoration.fromJson(Map<String, dynamic> json) => Decoration(
        id: json["id"],
        cardUrl: json["card_url"],
        jumpingUrl: json["jumping_url"],
        fan: json["fan"] == null ? null : Fan.fromJson(json["fan"]),
        idStr: json["id_str"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "card_url": cardUrl,
        "jumping_url": jumpingUrl,
        "fan": fan?.toJson(),
        "id_str": idStr,
      };
}

class Fan {
  Fan({
    this.isFan,
    this.number,
    this.color,
    this.name,
    this.numDesc,
  });

  int? isFan;
  int? number;
  String? color;
  String? name;
  String? numDesc;

  factory Fan.fromRawJson(String str) => Fan.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Fan.fromJson(Map<String, dynamic> json) => Fan(
        isFan: json["is_fan"],
        number: json["number"],
        color: json["color"],
        name: json["name"],
        numDesc: json["num_desc"],
      );

  Map<String, dynamic> toJson() => {
        "is_fan": isFan,
        "number": number,
        "color": color,
        "name": name,
        "num_desc": numDesc,
      };
}

class Honours {
  Honours({
    this.mid,
    this.colour,
    this.tags,
  });

  int? mid;
  String? colour;
  List<Tag>? tags;

  factory Honours.fromRawJson(String str) => Honours.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Honours.fromJson(Map<String, dynamic> json) => Honours(
        mid: json["mid"],
        colour: json["colour"],
        tags: json["tags"] == null
            ? []
            : List<Tag>.from(json["tags"]!.map((x) => Tag.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "mid": mid,
        "colour": colour,
        "tags": tags == null ? [] : List<dynamic>.from(tags!.map((x) => x.toJson())),
      };
}

class Tag {
  Tag({
    this.type,
    this.desc,
  });

  int? type;
  String? desc;

  factory Tag.fromRawJson(String str) => Tag.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Tag.fromJson(Map<String, dynamic> json) => Tag(
        type: json["type"],
        desc: json["desc"],
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "desc": desc,
      };
}

class LiveRoom {
  LiveRoom({
    this.roomStatus,
    this.liveStatus,
    this.url,
    this.title,
    this.cover,
    this.roomid,
    this.roundStatus,
    this.broadcastType,
    this.watchedShow,
  });

  int? roomStatus;
  int? liveStatus;
  String? url;
  String? title;
  String? cover;
  int? roomid;
  int? roundStatus;
  int? broadcastType;
  WatchedShow? watchedShow;

  factory LiveRoom.fromRawJson(String str) => LiveRoom.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory LiveRoom.fromJson(Map<String, dynamic> json) => LiveRoom(
        roomStatus: json["roomStatus"],
        liveStatus: json["liveStatus"],
        url: json["url"],
        title: json["title"],
        cover: json["cover"],
        roomid: json["roomid"],
        roundStatus: json["roundStatus"],
        broadcastType: json["broadcast_type"],
        watchedShow: json["watched_show"] == null
            ? null
            : WatchedShow.fromJson(json["watched_show"]),
      );

  Map<String, dynamic> toJson() => {
        "roomStatus": roomStatus,
        "liveStatus": liveStatus,
        "url": url,
        "title": title,
        "cover": cover,
        "roomid": roomid,
        "roundStatus": roundStatus,
        "broadcast_type": broadcastType,
        "watched_show": watchedShow?.toJson(),
      };
}

class WatchedShow {
  WatchedShow({
    this.switchValue,
    this.num,
    this.textSmall,
    this.textLarge,
    this.icon,
    this.nightIcon,
    this.count,
  });

  int? switchValue;
  int? num;
  String? textSmall;
  String? textLarge;
  String? icon;
  String? nightIcon;
  int? count;

  factory WatchedShow.fromRawJson(String str) =>
      WatchedShow.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory WatchedShow.fromJson(Map<String, dynamic> json) => WatchedShow(
        switchValue: json["switch"],
        num: json["num"],
        textSmall: json["text_small"],
        textLarge: json["text_large"],
        icon: json["icon"],
        nightIcon: json["night_icon"],
        count: json["count"],
      );

  Map<String, dynamic> toJson() => {
        "switch": switchValue,
        "num": num,
        "text_small": textSmall,
        "text_large": textLarge,
        "icon": icon,
        "night_icon": nightIcon,
        "count": count,
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

class Pendant {
  Pendant({
    this.pid,
    this.name,
    this.image,
    this.expire,
    this.imageEnhance,
    this.imageEnhanceFrame,
  });

  int? pid;
  String? name;
  String? image;
  int? expire;
  String? imageEnhance;
  String? imageEnhanceFrame;

  factory Pendant.fromRawJson(String str) => Pendant.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Pendant.fromJson(Map<String, dynamic> json) => Pendant(
        pid: json["pid"],
        name: json["name"],
        image: json["image"],
        expire: json["expire"],
        imageEnhance: json["image_enhance"],
        imageEnhanceFrame: json["image_enhance_frame"],
      );

  Map<String, dynamic> toJson() => {
        "pid": pid,
        "name": name,
        "image": image,
        "expire": expire,
        "image_enhance": imageEnhance,
        "image_enhance_frame": imageEnhanceFrame,
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

class SpaceTheme {
  SpaceTheme({
    this.id,
    this.skinId,
    this.preview,
    this.css,
    this.js,
    this.storage,
    this.isFree,
    this.isVip,
    this.isActivated,
    this.isCurrent,
  });

  int? id;
  int? skinId;
  String? preview;
  String? css;
  String? js;
  String? storage;
  bool? isFree;
  bool? isVip;
  bool? isActivated;
  bool? isCurrent;

  factory SpaceTheme.fromRawJson(String str) =>
      SpaceTheme.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory SpaceTheme.fromJson(Map<String, dynamic> json) => SpaceTheme(
        id: json["id"],
        skinId: json["skin_id"],
        preview: json["preview"],
        css: json["css"],
        js: json["js"],
        storage: json["storage"],
        isFree: json["is_free"],
        isVip: json["is_vip"],
        isActivated: json["is_activated"],
        isCurrent: json["is_current"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "skin_id": skinId,
        "preview": preview,
        "css": css,
        "js": js,
        "storage": storage,
        "is_free": isFree,
        "is_vip": isVip,
        "is_activated": isActivated,
        "is_current": isCurrent,
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
    this.avatarIcon,
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
  AvatarIcon? avatarIcon;

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
        avatarIcon: json["avatar_icon"] == null
            ? null
            : AvatarIcon.fromJson(json["avatar_icon"]),
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
        "avatar_icon": avatarIcon?.toJson(),
      };
}

class AvatarIcon {
  AvatarIcon({
    this.iconResource,
  });

  IconResource? iconResource;

  factory AvatarIcon.fromRawJson(String str) =>
      AvatarIcon.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory AvatarIcon.fromJson(Map<String, dynamic> json) => AvatarIcon(
        iconResource: json["icon_resource"] == null
            ? null
            : IconResource.fromJson(json["icon_resource"]),
      );

  Map<String, dynamic> toJson() => {
        "icon_resource": iconResource?.toJson(),
      };
}

class IconResource {
  IconResource({
    this.url,
    this.nightUrl,
  });

  String? url;
  String? nightUrl;

  factory IconResource.fromRawJson(String str) =>
      IconResource.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory IconResource.fromJson(Map<String, dynamic> json) => IconResource(
        url: json["url"],
        nightUrl: json["night_url"],
      );

  Map<String, dynamic> toJson() => {
        "url": url,
        "night_url": nightUrl,
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
    this.useImgLabel,
    this.imgLabelUriHans,
    this.imgLabelUriHant,
    this.imgLabelUriHansStatic,
    this.imgLabelUriHantStatic,
  });

  String? path;
  String? text;
  String? labelTheme;
  String? textColor;
  int? bgStyle;
  String? bgColor;
  String? borderColor;
  bool? useImgLabel;
  String? imgLabelUriHans;
  String? imgLabelUriHant;
  String? imgLabelUriHansStatic;
  String? imgLabelUriHantStatic;

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
        useImgLabel: json["use_img_label"],
        imgLabelUriHans: json["img_label_uri_hans"],
        imgLabelUriHant: json["img_label_uri_hant"],
        imgLabelUriHansStatic: json["img_label_uri_hans_static"],
        imgLabelUriHantStatic: json["img_label_uri_hant_static"],
      );

  Map<String, dynamic> toJson() => {
        "path": path,
        "text": text,
        "label_theme": labelTheme,
        "text_color": textColor,
        "bg_style": bgStyle,
        "bg_color": bgColor,
        "border_color": borderColor,
        "use_img_label": useImgLabel,
        "img_label_uri_hans": imgLabelUriHans,
        "img_label_uri_hant": imgLabelUriHant,
        "img_label_uri_hans_static": imgLabelUriHansStatic,
        "img_label_uri_hant_static": imgLabelUriHantStatic,
      };
}