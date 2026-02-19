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
    // dispose 시 구독 해제
    ref.onDispose(_cancelSubscription);
    return HomeState(feeds: []);
  }

  /// 스트림 구독 취소
  void _cancelSubscription() {
    _feedSubscription?.cancel();
    _feedSubscription = null;
  }

  /// 피드 정렬
  List<Post> _sortFeeds(List<Post> feeds, FeedSortType sortType) {
    switch (sortType) {
      case FeedSortType.mostLiked:
        feeds.sort((a, b) {
          final likeCompare = b.likeCount.compareTo(a.likeCount);
          return likeCompare != 0
              ? likeCompare
              : b.createdAt.compareTo(a.createdAt);
        });
        break;
      case FeedSortType.latest:
        feeds.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }
    return feeds;
  }

  /// 피드 로드
  Future<void> loadFeeds({FeedSortType? newSort, int? limit}) async {
    final targetLimit = limit ?? state.limit;
    final sortType = newSort ?? state.sortType;

    // 상태 업데이트 (로딩 표시 + 초기화)
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      sortType: sortType,
      limit: targetLimit,
    );

    _cancelSubscription();

    try {
      final fetchFeedsUseCase = ref.read(fetchFeedsUseCaseProvider);
      final currentUser = ref.read(userProvider).value;

      final stream = fetchFeedsUseCase.call(
        limit: targetLimit,
        userId: currentUser?.uid,
      );

      _feedSubscription = stream.listen(
        (fetchedFeeds) {
          final sortedFeeds = _sortFeeds(fetchedFeeds, sortType);

          state = state.copyWith(
            feeds: sortedFeeds,
            isLoading: false,
            hasMore: sortedFeeds.length >= targetLimit,
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

  /// 무한 스크롤용 더 보기
  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;
    await loadFeeds(limit: state.limit + 20);
  }

  /// 새로고침
  Future<void> refresh() async {
    await loadFeeds(limit: 20, newSort: state.sortType);
  }

  /// 게시글 삭제
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
