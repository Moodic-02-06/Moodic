import 'package:flutter_moodic/domain/repository/user_repository.dart';

class UnfollowUserUseCase {
  final UserRepository repository;

  UnfollowUserUseCase(this.repository);

  Future<void> call(String uid, String targetUid) async {
    return repository.unfollowUser(uid, targetUid);
  }
}
