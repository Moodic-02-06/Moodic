import 'package:flutter_moodic/domain/entity/user_entity.dart';

//인터페이스
abstract class UserRepository {
  Future<UserEntity?> getUser(String uid);
  Future<void> updateUser(UserEntity user);
  Future<void> deleteUser(String uid);
  Future<void> saveUser(UserEntity user);
  Future<String> uploadProfileImage(String path, String userId);
}
