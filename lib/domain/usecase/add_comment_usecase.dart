import '../repository/post_repository.dart';

class AddCommentUseCase {
  final PostRepository repository;

  AddCommentUseCase(this.repository);

  Future<void> call(
    String postId,
    String userId,
    String content,
    String nickname,
    String profileImageUrl,
  ) async {
    await repository.addComment(
      postId,
      userId,
      content,
      nickname,
      profileImageUrl,
    );
  }
}
