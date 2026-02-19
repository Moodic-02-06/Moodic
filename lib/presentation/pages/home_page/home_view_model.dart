import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_moodic/domain/entity/post.dart';
import 'package:flutter_moodic/presentation/provider/use_case_provider.dart';
import 'package:flutter_moodic/presentation/provider/user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeState {
  final List<Post> feeds;
  final bool isLoading;
  final String? errorMessage;
  final int limit;
  final bool hasMore;

  HomeState({
    required this.feeds,
    this.isLoading = false,
    this.errorMessage,
    this.limit = 20,
    this.hasMore = true,
  });

  HomeState copyWith({
    List<Post>? feeds,
    bool? isLoading,
    String? errorMessage,
    int? limit,
    bool? hasMore,
  }) {
    return HomeState(
      feeds: feeds ?? this.feeds,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      limit: limit ?? this.limit,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class HomeViewModel extends Notifier<HomeState> {
  StreamSubscription<List<Post>>? _feedSubscription;

  @override
  HomeState build() {
    ref.onDispose(_cancelSubscription);
    return HomeState(feeds: []);
  }

  void _cancelSubscription() {
    _feedSubscription?.cancel();
    _feedSubscription = null;
  }

  /// 피드 로드 (최신순 고정)
  Future<void> loadFeeds({int? limit}) async {
    final targetLimit = limit ?? state.limit;

    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
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
          // 최신순으로 정렬 (createdAt 내림차순)
          final sorted = List<Post>.from(fetchedFeeds)
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

          state = state.copyWith(
            feeds: sorted,
            isLoading: false,
            hasMore: sorted.length >= targetLimit,
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
    await loadFeeds(limit: 20);
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
