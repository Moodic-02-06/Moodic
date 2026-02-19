import 'package:flutter_moodic/domain/repository/user_repository.dart';

class GetFollowingUseCase {
  final UserRepository repository;

  GetFollowingUseCase(this.repository);

  Future<List<String>> call(String uid) async {
    return repository.getFollowing(uid);
  }
}
