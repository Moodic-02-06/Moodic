import '../repository/post_repository.dart';

class UploadImagesUseCase {
  final PostRepository repository;

  UploadImagesUseCase(this.repository);

  Future<List<String>> call(String userId, List<String> images) async {
    return await repository.uploadImages(userId, images);
  }
}
