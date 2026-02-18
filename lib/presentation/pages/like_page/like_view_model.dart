import 'package:flutter_moodic/presentation/provider/repository_provider.dart';
import 'package:flutter_moodic/domain/entity/post.dart';
import 'package:flutter_moodic/domain/usecase/fetch_liked_posts_usecase.dart';
import 'package:flutter_moodic/presentation/provider/user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 좋아요한 피드 목록 가져오기 UseCase Provider
final fetchLikedPostsUseCaseProvider = Provider<FetchLikedPostsUseCase>((ref) {
  final repository = ref.watch(postRepositoryProvider);
  return FetchLikedPostsUseCase(repository);
});

/// Like 페이지 상태 (로딩, 에러, 데이터)
/// FutureProvider를 사용하여 비동기 데이터 로딩 및 상태 관리
final likeFeedsProvider = StreamProvider.autoDispose<List<Post>>((ref) {
  final user = ref.watch(userProvider);
  final userId = user.value?.uid;

  // 비로그인 상태면 빈 리스트 반환
  if (userId == null) {
    return Stream.value([]);
  }

  final useCase = ref.watch(fetchLikedPostsUseCaseProvider);
  return useCase.call(userId);
});
