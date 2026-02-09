import 'package:flutter_moodic/domain/entity/user_entity.dart';

class UserDto extends UserEntity {
  UserDto({required super.uid});

  // fromJson: 파이어베이스에서 가져온 데이터를 이 클래스 형태로 변환함
  factory UserDto.fromJson(Map<String, dynamic> map) {
    return UserDto(uid: map['uid']);
  }

  // toJson: 이 클래스를 파이어베이스에 저장할 수 있게 Map으로 변환함
  Map<String, dynamic> toJson() {
    return {'uid': uid};
  }

  // toEntity: DTO를 순수한 엔티티로 바꿔서 도메인 계층으로 올려보낼 때 씀
  UserEntity toEntity() {
    return UserEntity(uid: uid);
  }
}
