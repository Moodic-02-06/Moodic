import '../repositories/post_repository.dart';

class AddCommentUseCase {
  final PostRepository repository;

  AddCommentUseCase(this.repository);

  Future<void> call(String postId, String userId, String content) async {
    await repository.addComment(postId, userId, content);
  }
}
