import 'package:flutter_moodic/domain/repository/user_repository.dart';

class CheckFollowStatusUseCase {
  final UserRepository repository;

  CheckFollowStatusUseCase(this.repository);

  Future<bool> call(String uid, String targetUid) async {
    return repository.isFollowing(uid, targetUid);
  }
}
