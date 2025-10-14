import 'dart:convert';

class LoginUserInfoResponse {
  LoginUserInfoResponse({
    this.code,
    this.message,
    this.ttl,
    this.data,
  });

  int? code;
  String? message;
  int? ttl;
  LoginUserInfoData? data;

  factory LoginUserInfoResponse.fromRawJson(String str) =>
      LoginUserInfoResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory LoginUserInfoResponse.fromJson(Map<String, dynamic> json) =>
      LoginUserInfoResponse(
        code: json["code"],
        message: json["message"],
        ttl: json["ttl"],
        data: json["data"] == null ? null : LoginUserInfoData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "message": message,
        "ttl": ttl,
        "data": data?.toJson(),
      };
}

class LoginUserInfoData {
  LoginUserInfoData({
    this.mid,
    this.uname,
    this.userid,
    this.sign,
    this.birthday,
    this.sex,
    this.nickFree,
    this.rank,
    this.face,
    this.faceNft,
    this.faceNftNew,
    this.isSilence,
    this.inRegAudit,
    this.isTeenager,
    this.isNewbie,
    this.isFakeAccount,
    this.isRenew,
    this.isElder,
    this.levelInfo,
    this.pendant,
    this.nameplate,
    this.officialVerify,
    this.vip,
    this.isLogin,
  });

  int? mid;
  String? uname;
  String? userid;
  String? sign;
  String? birthday;
  String? sex;
  int? nickFree;
  int? rank;
  String? face;
  int? faceNft;
  int? faceNftNew;
  int? isSilence;
  int? inRegAudit;
  int? isTeenager;
  int? isNewbie;
  int? isFakeAccount;
  int? isRenew;
  int? isElder;
  LevelInfo? levelInfo;
  Pendant? pendant;
  Nameplate? nameplate;
  OfficialVerify? officialVerify;
  Vip? vip;
  bool? isLogin;

  factory LoginUserInfoData.fromRawJson(String str) =>
      LoginUserInfoData.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory LoginUserInfoData.fromJson(Map<String, dynamic> json) =>
      LoginUserInfoData(
        mid: json["mid"],
        uname: json["uname"],
        userid: json["userid"],
        sign: json["sign"],
        birthday: json["birthday"],
        sex: json["sex"],
        nickFree: json["nick_free"],
        rank: json["rank"],
        face: json["face"],
        faceNft: json["face_nft"],
        faceNftNew: json["face_nft_new"],
        isSilence: json["is_silence"],
        inRegAudit: json["in_reg_audit"],
        isTeenager: json["is_teenager"],
        isNewbie: json["is_newbie"],
        isFakeAccount: json["is_fake_account"],
        isRenew: json["is_renew"],
        isElder: json["is_elder"],
        levelInfo: json["level_info"] == null
            ? null
            : LevelInfo.fromJson(json["level_info"]),
        pendant:
            json["pendant"] == null ? null : Pendant.fromJson(json["pendant"]),
        nameplate: json["nameplate"] == null
            ? null
            : Nameplate.fromJson(json["nameplate"]),
        officialVerify: json["official_verify"] == null
            ? null
            : OfficialVerify.fromJson(json["official_verify"]),
        vip: json["vip"] == null ? null : Vip.fromJson(json["vip"]),
        isLogin: json["isLogin"],
      );

  Map<String, dynamic> toJson() => {
        "mid": mid,
        "uname": uname,
        "userid": userid,
        "sign": sign,
        "birthday": birthday,
        "sex": sex,
        "nick_free": nickFree,
        "rank": rank,
        "face": face,
        "face_nft": faceNft,
        "face_nft_new": faceNftNew,
        "is_silence": isSilence,
        "in_reg_audit": inRegAudit,
        "is_teenager": isTeenager,
        "is_newbie": isNewbie,
        "is_fake_account": isFakeAccount,
        "is_renew": isRenew,
        "is_elder": isElder,
        "level_info": levelInfo?.toJson(),
        "pendant": pendant?.toJson(),
        "nameplate": nameplate?.toJson(),
        "official_verify": officialVerify?.toJson(),
        "vip": vip?.toJson(),
        "isLogin": isLogin,
      };
}

class LevelInfo {
  LevelInfo({
    this.currentLevel,
    this.currentMin,
    this.currentExp,
    this.nextExp,
  });

  int? currentLevel;
  int? currentMin;
  int? currentExp;
  int? nextExp;

  factory LevelInfo.fromRawJson(String str) =>
      LevelInfo.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory LevelInfo.fromJson(Map<String, dynamic> json) => LevelInfo(
        currentLevel: json["current_level"],
        currentMin: json["current_min"],
        currentExp: json["current_exp"],
        nextExp: json["next_exp"],
      );

  Map<String, dynamic> toJson() => {
        "current_level": currentLevel,
        "current_min": currentMin,
        "current_exp": currentExp,
        "next_exp": nextExp,
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

class OfficialVerify {
  OfficialVerify({
    this.type,
    this.desc,
  });

  int? type;
  String? desc;

  factory OfficialVerify.fromRawJson(String str) =>
      OfficialVerify.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory OfficialVerify.fromJson(Map<String, dynamic> json) => OfficialVerify(
        type: json["type"],
        desc: json["desc"],
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "desc": desc,
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