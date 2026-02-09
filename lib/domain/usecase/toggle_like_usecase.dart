import '../repositories/post_repository.dart';

class ToggleLikeUseCase {
  final PostRepository repository;

  ToggleLikeUseCase(this.repository);

  Future<void> call(String postId, String userId, bool isLiked) async {
    await repository.toggleLike(postId, userId, isLiked);
  }
}
