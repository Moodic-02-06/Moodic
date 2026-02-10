import 'package:flutter_moodic/domain/entity/user_entity.dart';

class UserDto extends UserEntity {
  UserDto({
    required super.uid,
    required super.nickname,
    required super.profileImage,
    required super.bio,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      uid: json['uid'] as String? ?? '',
      // 핵심: 서버에 데이터가 없어도 빈 문자열을 넣어 required를 만족시킴
      nickname: json['nickname'] as String? ?? '닉네임 없음',
      profileImage: json['profileImage'] as String? ?? '',
      bio: json['bio'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'nickname': nickname,
      'profileImage': profileImage,
      'bio': bio,
    };
  }
}
