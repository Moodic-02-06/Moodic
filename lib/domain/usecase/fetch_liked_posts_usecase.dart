import 'package:flutter_moodic/domain/entity/post.dart';
import 'package:flutter_moodic/domain/repository/post_repository.dart';

class FetchLikedPostsUseCase {
  final PostRepository _repository;

  FetchLikedPostsUseCase(this._repository);

  Stream<List<Post>> call(String userId) {
    return _repository.getLikedPostsStream(userId);
  }
}
