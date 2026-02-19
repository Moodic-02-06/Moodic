import 'package:flutter_moodic/domain/usecase/delete_post_usecase.dart';
import 'package:flutter_moodic/domain/usecase/fetch_feeds_usecase.dart';
import 'package:flutter_moodic/domain/usecase/toggle_like_usecase.dart';
import 'package:flutter_moodic/domain/usecase/update_post_usecase.dart';
import 'package:flutter_moodic/presentation/provider/repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final toggleLikeUseCaseProvider = Provider<ToggleLikeUseCase>((ref) {
  return ToggleLikeUseCase(ref.read(postRepositoryProvider));
});

final deletePostUseCaseProvider = Provider<DeletePostUseCase>((ref) {
  return DeletePostUseCase(ref.read(postRepositoryProvider));
});

final updatePostUseCaseProvider = Provider<UpdatePostUseCase>((ref) {
  return UpdatePostUseCase(ref.read(postRepositoryProvider));
});

final fetchFeedsUseCaseProvider = Provider<FetchFeedsUseCase>((ref) {
  final repo = ref.read(postRepositoryProvider);
  return FetchFeedsUseCase(repo);
});
