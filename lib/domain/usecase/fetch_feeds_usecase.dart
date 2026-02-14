import 'package:flutter_moodic/domain/entity/post.dart';
import 'package:flutter_moodic/domain/repository/post_repository.dart';

class FetchFeedsUseCase {
  final PostRepository repository;

  FetchFeedsUseCase(this.repository);

  Future<List<Post>> call({
    int limit = 20,
    String? userId,
    String? authorId,
  }) async {
    return await repository.fetchFeeds(
      limit: limit,
      userId: userId,
      authorId: authorId,
    );
  }
}
