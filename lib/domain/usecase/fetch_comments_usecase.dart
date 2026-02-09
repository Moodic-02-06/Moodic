import 'package:flutter_moodic/domain/entity/comment.dart';
import 'package:flutter_moodic/domain/repositories/post_repository.dart';

class FetchCommentsUseCase {
  final PostRepository repository;

  FetchCommentsUseCase(this.repository);

  Future<List<Comment>> call(String postId) async {
    return await repository.fetchComments(postId);
  }
}
