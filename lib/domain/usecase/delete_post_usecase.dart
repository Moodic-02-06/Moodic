import 'package:flutter_moodic/domain/repository/post_repository.dart';

class DeletePostUseCase {
  final PostRepository _repository;

  DeletePostUseCase(this._repository);

  Future<void> execute(String postId) async {
    await _repository.deletePost(postId);
  }
}
