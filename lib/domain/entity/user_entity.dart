class UserEntity {
  final String uid;
  final String nickname;
  final String? profileImage;
  final String? bio;
  final bool isFirst;

  UserEntity({
    required this.uid,
    required this.nickname,
    required this.profileImage,
    required this.bio,
    this.isFirst = false,
  });

  UserEntity copyWith({
    String? uid,
    String? nickname,
    String? profileImage,
    String? bio,
    bool? isFirst,
  }) {
    return UserEntity(
      uid: uid ?? this.uid,
      nickname: nickname ?? this.nickname,
      profileImage: profileImage ?? this.profileImage,
      bio: bio ?? this.bio,
      isFirst: isFirst ?? this.isFirst,
    );
  }
}
