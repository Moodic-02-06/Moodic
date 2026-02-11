import 'package:flutter_moodic/data/data_source/user_remote_data_source.dart';
import 'package:flutter_moodic/data/dto/user_dto.dart';
import 'package:flutter_moodic/domain/entity/user_entity.dart';
import 'package:flutter_moodic/domain/repository/user_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource _dataSource;

  UserRepositoryImpl(this._dataSource);

  @override
  Future<UserEntity?> getUser(String uid) async {
    final dto = await _dataSource.getUserData(uid);
    return dto;
  }

  @override
  Future<void> deleteUser(String uid) async {
    await _dataSource.deleteUser(uid);
  }

  @override
  Future<void> updateUser(UserEntity user) async {
    final dto = UserDto(
      uid: user.uid,
      nickname: user.nickname,
      profileImage: user.profileImage,
      bio: user.bio,
      isFirst: user.isFirst,
    );
    await _dataSource.updateUser(dto);
  }

  @override
  Future<void> saveUser(UserEntity user) async {
    // 뷰모델에서 받은 유저 정보를 DTO로 포장해서 소스로 이동
    final userDto = UserDto(
      uid: user.uid,
      nickname: user.nickname,
      profileImage: user.profileImage,
      bio: user.bio,
      isFirst: user.isFirst,
    );
    await _dataSource.saveUser(userDto);
  }
}

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepositoryImpl(UserRemoteDataSource());
});
