import 'package:flutter_moodic/domain/entity/post.dart';
import 'package:flutter_moodic/domain/repository/post_repository.dart';

class FetchUserPostsUseCase {
  final PostRepository repository;

  FetchUserPostsUseCase(this.repository);

  Stream<List<Post>> call(String userId) {
    return repository.getFeedsStream(
      limit: 50, // 마이페이지는 더 많이?
      authorId: userId,
      userId: userId, // 내 좋아요 상태도 확인해야 하므로
    );
  }
}
