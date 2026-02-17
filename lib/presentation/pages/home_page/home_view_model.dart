import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_moodic/domain/entity/post.dart';
import 'package:flutter_moodic/presentation/provider/use_case_provider.dart';
import 'package:flutter_moodic/presentation/provider/user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum FeedSortType { latest, mostLiked }

class HomeState {
  final List<Post> feeds;
  final bool isLoading;
  final String? errorMessage;
  final FeedSortType sortType;
  final int limit;
  final bool hasMore;

  HomeState({
    required this.feeds,
    this.isLoading = false,
    this.errorMessage,
    this.sortType = FeedSortType.latest,
    this.limit = 20,
    this.hasMore = true,
  });

  HomeState copyWith({
    List<Post>? feeds,
    bool? isLoading,
    String? errorMessage,
    FeedSortType? sortType,
    int? limit,
    bool? hasMore,
  }) {
    return HomeState(
      feeds: feeds ?? this.feeds,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      sortType: sortType ?? this.sortType,
      limit: limit ?? this.limit,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class HomeViewModel extends Notifier<HomeState> {
  StreamSubscription<List<Post>>? _feedSubscription;

  @override
  HomeState build() {
    ref.onDispose(() {
      _feedSubscription?.cancel();
    });
    return HomeState(feeds: []);
  }

  Future<void> loadFeeds({FeedSortType? newSort, int? limit}) async {
    final targetLimit = limit ?? state.limit;

    // 상태 업데이트 (로딩 표시)
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      sortType: newSort ?? state.sortType,
      limit: targetLimit,
    );

    _feedSubscription?.cancel();

    try {
      final fetchFeedsUseCase = ref.read(fetchFeedsUseCaseProvider);

      final currentUser = ref.read(userProvider).value;

      final stream = fetchFeedsUseCase.call(
        limit: targetLimit,
        userId: currentUser?.uid,
      );

      _feedSubscription = stream.listen(
        (fetchedFeeds) {
          // 정렬 로직
          if (state.sortType == FeedSortType.mostLiked) {
            fetchedFeeds.sort((a, b) {
              // 1순위: 좋아요 수 내림차순
              final compare = b.likeCount.compareTo(a.likeCount);
              // 2순위: 작성일 내림차순 (좋아요 수가 같을 경우)
              if (compare == 0) {
                return b.createdAt.compareTo(a.createdAt);
              }
              return compare;
            });
          } else {
            // 최신순
            fetchedFeeds.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          }

          state = state.copyWith(
            feeds: fetchedFeeds,
            isLoading: false,
            hasMore: fetchedFeeds.length == targetLimit,
          );
        },
        onError: (e) {
          debugPrint('피드 로드 실패: $e');
          state = state.copyWith(errorMessage: e.toString(), isLoading: false);
        },
      );
    } catch (e) {
      debugPrint('피드 스트림 연결 실패: $e');
      state = state.copyWith(errorMessage: e.toString(), isLoading: false);
    }
  }

  /// 더 보기 (무한 스크롤)
  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;

    final newLimit = state.limit + 20;
    await loadFeeds(limit: newLimit);
  }

  /// 새로고침 (초기화)
  Future<void> refresh() async {
    state = state.copyWith(limit: 20, feeds: [], hasMore: true);

    await loadFeeds(limit: 20);
  }

  Future<void> deletePost(String postId) async {
    try {
      await ref.read(deletePostUseCaseProvider).execute(postId);
    } catch (e) {
      debugPrint('게시글 삭제 실패: $e');
    }
  }
}

final homeViewModelProvider = NotifierProvider<HomeViewModel, HomeState>(
  () => HomeViewModel(),
);
