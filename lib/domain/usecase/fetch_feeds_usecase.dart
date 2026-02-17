import 'package:flutter_moodic/domain/entity/post.dart';
import 'package:flutter_moodic/domain/repository/post_repository.dart';

class FetchFeedsUseCase {
  final PostRepository repository;

  FetchFeedsUseCase(this.repository);

  Stream<List<Post>> call({int limit = 20, String? userId, String? authorId}) {
    return repository.getFeedsStream(
      limit: limit,
      userId: userId,
      authorId: authorId,
    );
  }
}
