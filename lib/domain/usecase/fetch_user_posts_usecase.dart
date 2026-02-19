import 'package:flutter_moodic/domain/entity/post.dart';
import 'package:flutter_moodic/domain/repository/post_repository.dart';

class FetchUserPostsUseCase {
  final PostRepository repository;

  FetchUserPostsUseCase(this.repository);

  Stream<List<Post>> call(String authorId, {String? currentUserId}) {
    return repository.getFeedsStream(
      limit: 50,
      authorId: authorId,
      userId: currentUserId, // 내 좋아요 상태 확인용 (로그인한 유저 ID)
    );
  }
}
