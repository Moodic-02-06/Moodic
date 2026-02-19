import 'package:flutter_moodic/domain/repository/user_repository.dart';

class GetFollowersUseCase {
  final UserRepository repository;

  GetFollowersUseCase(this.repository);

  Future<List<String>> call(String uid) async {
    return repository.getFollowers(uid);
  }
}
