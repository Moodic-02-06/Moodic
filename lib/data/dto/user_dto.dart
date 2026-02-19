import 'package:flutter_moodic/domain/entity/user_entity.dart';

class UserDto extends UserEntity {
  UserDto({
    required super.uid,
    required super.nickname,
    required super.profileImage,
    required super.bio,
    required super.isFirst,
    required super.postCount,
    required super.followerCount,
    required super.followingCount,
    required super.isNotificationEnabled,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      uid: json['uid'] as String? ?? '',
      nickname: json['nickname'] as String? ?? '닉네임 없음',
      profileImage: json['profileImage'] as String? ?? '',
      bio: json['bio'] as String? ?? '',
      isFirst: json['isFirst'] as bool? ?? true,
      postCount: json['postCount'] as int? ?? 0,
      followerCount: json['followerCount'] as int? ?? 0,
      followingCount: json['followingCount'] as int? ?? 0,
      isNotificationEnabled: json['isNotificationEnabled'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'nickname': nickname,
      'profileImage': profileImage,
      'bio': bio,
      'isFirst': isFirst,
      'postCount': postCount,
      'followerCount': followerCount,
      'followingCount': followingCount,
      'isNotificationEnabled': isNotificationEnabled,
    };
  }

  UserEntity toEntity() {
    return UserEntity(
      uid: uid,
      nickname: nickname,
      profileImage: profileImage,
      bio: bio,
      isFirst: isFirst,
      postCount: postCount,
      followerCount: followerCount,
      followingCount: followingCount,
      isNotificationEnabled: isNotificationEnabled,
    );
  }
}
