import 'package:flutter_moodic/domain/repository/user_repository.dart';

class FollowUserUseCase {
  final UserRepository repository;

  FollowUserUseCase(this.repository);

  Future<void> call(String uid, String targetUid) async {
    return repository.followUser(uid, targetUid);
  }
}
