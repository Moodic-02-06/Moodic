// presentation/provider/write_provider.dart
import 'package:flutter_moodic/presentation/pages/write_page/post_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecase/create_post_usecase.dart';

final createPostUseCaseProvider = Provider<CreatePostUseCase>((ref) {
  final repository = ref.watch(postRepositoryProvider);
  return CreatePostUseCase(repository);
});
