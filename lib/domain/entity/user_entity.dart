class UserEntity {
  final String uid;
  final String nickname;
  final String? profileImage;
  final String? bio;
  final bool isFirst;
  final int postCount;
  final int followerCount;
  final int followingCount;
  final bool isNotificationEnabled;
  final String? fcmToken;

  UserEntity({
    required this.uid,
    required this.nickname,
    required this.profileImage,
    required this.bio,
    this.isFirst = false,
    this.postCount = 0,
    required this.followerCount,
    required this.followingCount,
    this.isNotificationEnabled = true,
    this.fcmToken,
  });

  UserEntity copyWith({
    String? uid,
    String? nickname,
    String? profileImage,
    String? bio,
    bool? isFirst,
    int? postCount,
    int? followerCount,
    int? followingCount,
    bool? isNotificationEnabled,
    String? fcmToken,
  }) {
    return UserEntity(
      uid: uid ?? this.uid,
      nickname: nickname ?? this.nickname,
      profileImage: profileImage ?? this.profileImage,
      bio: bio ?? this.bio,
      isFirst: isFirst ?? this.isFirst,
      postCount: postCount ?? this.postCount,
      followerCount: followerCount ?? this.followerCount,
      followingCount: followingCount ?? this.followingCount,
      isNotificationEnabled:
          isNotificationEnabled ?? this.isNotificationEnabled,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }
}
