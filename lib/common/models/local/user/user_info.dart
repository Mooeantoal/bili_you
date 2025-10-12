class UserInfo {
  final int mid;
  final String name;
  final String face;
  final String sign;
  final int level;
  final int gender;
  final int rank;
  final int silence;
  final String birthday;
  final int coins;
  final bool following;
  final int follower;
  final int followingCount;
  final int archiveCount;
  final int articleCount;
  final int liveRoomStatus;
  final int likeNum;

  UserInfo({
    required this.mid,
    required this.name,
    required this.face,
    required this.sign,
    required this.level,
    required this.gender,
    required this.rank,
    required this.silence,
    required this.birthday,
    required this.coins,
    required this.following,
    required this.follower,
    required this.followingCount,
    required this.archiveCount,
    required this.articleCount,
    required this.liveRoomStatus,
    required this.likeNum,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      mid: json['mid'] ?? 0,
      name: json['name'] ?? '',
      face: json['face'] ?? '',
      sign: json['sign'] ?? '',
      level: json['level'] ?? 0,
      gender: json['sex'] ?? 0,
      rank: json['rank'] ?? 0,
      silence: json['silence'] ?? 0,
      birthday: json['birthday'] ?? '',
      coins: (json['coins'] as num?)?.toInt() ?? 0,
      following: json['following'] ?? false,
      follower: json['follower'] ?? 0,
      followingCount: json['following_count'] ?? 0,
      archiveCount: json['archive_count'] ?? 0,
      articleCount: json['article_count'] ?? 0,
      liveRoomStatus: json['live_room_status'] ?? 0,
      likeNum: json['like_num'] ?? 0,
    );
  }
}