import 'package:flutter_moodic/domain/repository/user_repository.dart';

class FollowUserUseCase {
  final UserRepository repository;

  FollowUserUseCase(this.repository);

  Future<void> call(
    String uid,
    String targetUid, {
    required String senderNickname,
    required String senderProfileImage,
  }) async {
    return repository.followUser(
      uid,
      targetUid,
      senderNickname: senderNickname,
      senderProfileImage: senderProfileImage,
    );
  }
}
