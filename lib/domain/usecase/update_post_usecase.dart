import 'package:flutter_moodic/domain/entity/post.dart';
import 'package:flutter_moodic/domain/repository/post_repository.dart';

class UpdatePostUseCase {
  final PostRepository repository;

  UpdatePostUseCase(this.repository);

  Future<void> call(Post post) async {
    await repository.updatePost(post);
  }
}
