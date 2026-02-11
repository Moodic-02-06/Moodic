import 'package:flutter/material.dart';
import 'package:flutter_moodic/domain/entity/post.dart';
import 'package:flutter_moodic/domain/usecase/fetch_feeds_usecase.dart';
import 'package:flutter_moodic/domain/usecase/toggle_like_usecase.dart';
import 'package:flutter_moodic/presentation/pages/write_page/post_repository_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum FeedSortType { latest, mostLiked }

class HomeState {
  final List<Post> feeds;
  final bool isLoading;
  final String? errorMessage;
  final FeedSortType sortType;

  HomeState({
    required this.feeds,
    this.isLoading = false,
    this.errorMessage,
    this.sortType = FeedSortType.latest,
  });

  HomeState copyWith({
    List<Post>? feeds,
    bool? isLoading,
    String? errorMessage,
    FeedSortType? sortType,
  }) {
    return HomeState(
      feeds: feeds ?? this.feeds,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      sortType: sortType ?? this.sortType,
    );
  }
}

class HomeViewModel extends Notifier<HomeState> {
  @override
  HomeState build() => HomeState(feeds: []);

  Future<void> loadFeeds({FeedSortType? newSort}) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      sortType: newSort ?? state.sortType,
    );

    try {
      // build() 외부에서 의존성을 가져올 때는 ref.read를 사용
      final repository = ref.read(postRepositoryProvider);
      final fetchFeedsUseCase = FetchFeedsUseCase(repository);

      var fetchedFeeds = await fetchFeedsUseCase.call(limit: 50);

      // 정렬 로직
      if ((newSort ?? state.sortType) == FeedSortType.mostLiked) {
        fetchedFeeds.sort((a, b) => b.likeCount.compareTo(a.likeCount));
      } else {
        fetchedFeeds.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }

      state = state.copyWith(feeds: fetchedFeeds, isLoading: false);
    } catch (e) {
      debugPrint('Feed Load Error: $e');
      state = state.copyWith(errorMessage: e.toString(), isLoading: false);
    }
  }

  Future<void> toggleLike(Post post, String userId) async {
    final isCurrentlyLiked = post.isLikedByMe;

    final repository = ref.read(postRepositoryProvider);
    final toggleLikeUseCase = ToggleLikeUseCase(repository);

    await toggleLikeUseCase.call(post.postId, userId, isCurrentlyLiked);

    final updatedFeeds = state.feeds.map((p) {
      if (p.postId == post.postId) {
        return p.copyWith(
          likeCount: isCurrentlyLiked ? p.likeCount - 1 : p.likeCount + 1,
          isLikedByMe: !isCurrentlyLiked,
        );
      }
      return p;
    }).toList();

    state = state.copyWith(feeds: updatedFeeds);
  }
}

final homeViewModelProvider = NotifierProvider<HomeViewModel, HomeState>(
  () => HomeViewModel(),
);
