class UserEntity {
  final String uid;
  final String nickname;
  final String? profileImage;
  final String? bio;

  UserEntity({
    required this.uid,
    required this.nickname,
    required this.profileImage,
    required this.bio,
  });
}
