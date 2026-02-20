import 'package:flutter_moodic/domain/entity/user_entity.dart';

//인터페이스
abstract class UserRepository {
  Future<UserEntity?> getUser(String uid);
  Future<void> updateUser(UserEntity user);
  Future<void> deleteUser(String uid);
  Future<void> saveUser(UserEntity user);
  Future<String> uploadProfileImage(String path, String userId);
  Future<void> followUser(String uid, String targetUid);
  Future<void> unfollowUser(String uid, String targetUid);
  Future<bool> isFollowing(String uid, String targetUid);
  Future<List<String>> getFollowers(String uid);
  Future<List<String>> getFollowing(String uid);
  Future<void> updateFcmToken(String uid, String token);
}
