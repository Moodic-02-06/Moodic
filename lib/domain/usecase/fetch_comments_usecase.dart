import 'package:flutter_moodic/domain/entity/comment.dart';
import 'package:flutter_moodic/domain/repository/post_repository.dart';

class FetchCommentsUseCase {
  final PostRepository repository;

  FetchCommentsUseCase(this.repository);

  Stream<List<Comment>> call(String postId) {
    return repository.getCommentsStream(postId);
  }
}
