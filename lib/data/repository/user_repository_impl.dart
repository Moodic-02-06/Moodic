import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_moodic/data/data_source/firebase_storage_data_source.dart';
import 'package:flutter_moodic/data/data_source/user_remote_data_source.dart';
import 'package:flutter_moodic/data/dto/user_dto.dart';
import 'package:flutter_moodic/domain/entity/user_entity.dart';
import 'package:flutter_moodic/domain/repository/user_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource _dataSource;
  final FirebaseStorageDataSource _storageDataSource;

  UserRepositoryImpl(this._dataSource, this._storageDataSource);

  @override
  Future<UserEntity?> getUser(String uid) async {
    final dto = await _dataSource.getUserData(uid);
    if (dto == null) return null;

    return dto.toEntity();
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
      postCount: user.postCount,
      followerCount: user.followerCount,
      followingCount: user.followingCount,
      isNotificationEnabled: user.isNotificationEnabled,
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
      postCount: user.postCount,
      followerCount: user.followerCount,
      followingCount: user.followingCount,
      isNotificationEnabled: user.isNotificationEnabled,
    );
    await _dataSource.saveUser(userDto);
  }

  @override
  Future<String> uploadProfileImage(String path, String userId) async {
    return _storageDataSource.uploadImage(
      path: path,
      fileName:
          'users/$userId/profile_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
  }

  @override
  Future<void> followUser(String uid, String targetUid) async {
    await _dataSource.followUser(uid, targetUid);
  }

  @override
  Future<void> unfollowUser(String uid, String targetUid) async {
    await _dataSource.unfollowUser(uid, targetUid);
  }

  @override
  Future<bool> isFollowing(String uid, String targetUid) async {
    return await _dataSource.isFollowing(uid, targetUid);
  }

  @override
  Future<List<String>> getFollowers(String uid) async {
    return await _dataSource.getFollowers(uid);
  }

  @override
  Future<List<String>> getFollowing(String uid) async {
    return await _dataSource.getFollowing(uid);
  }
}

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepositoryImpl(
    UserRemoteDataSource(),
    FirebaseStorageDataSource(FirebaseStorage.instance),
  );
});
