import 'package:flutter/material.dart';
import 'package:flutter_moodic/domain/entity/post.dart';
import 'package:flutter_moodic/domain/usecase/fetch_feeds_usecase.dart';
import 'package:flutter_moodic/presentation/pages/write_page/post_repository_provider.dart';
import 'package:flutter_moodic/presentation/provider/use_case_provider.dart';
import 'package:flutter_moodic/presentation/provider/user_provider.dart';
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

      // 현재 로그인한 유저 정보 가져오기
      final currentUser = ref.read(userProvider).value;

      var fetchedFeeds = await fetchFeedsUseCase.call(
        limit: 50,
        userId: currentUser?.uid,
      );

      // 정렬 로직
      if ((newSort ?? state.sortType) == FeedSortType.mostLiked) {
        fetchedFeeds.sort((a, b) => b.likeCount.compareTo(a.likeCount));
      } else {
        fetchedFeeds.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }

      state = state.copyWith(feeds: fetchedFeeds, isLoading: false);
    } catch (e) {
      debugPrint('피드 로드 실패: $e');
      state = state.copyWith(errorMessage: e.toString(), isLoading: false);
    }
  }

  void removePost(String postId) {
    state = state.copyWith(
      feeds: state.feeds.where((p) => p.postId != postId).toList(),
    );
  }

  Future<void> deletePost(String postId) async {
    try {
      await ref.read(deletePostUseCaseProvider).execute(postId);
      removePost(postId);
    } catch (e) {
      debugPrint('게시글 삭제 실패: $e');
    }
  }

  void syncLikeStatus(String postId, bool isLiked, int likeCount) {
    state = state.copyWith(
      feeds: state.feeds.map((p) {
        if (p.postId == postId) {
          return p.copyWith(isLikedByMe: isLiked, likeCount: likeCount);
        }
        return p;
      }).toList(),
    );
  }

  void syncCommentCount(String postId, int newCount) {
    state = state.copyWith(
      feeds: state.feeds.map((p) {
        if (p.postId == postId) {
          return p.copyWith(commentCount: newCount);
        }
        return p;
      }).toList(),
    );
  }
}

final homeViewModelProvider = NotifierProvider<HomeViewModel, HomeState>(
  () => HomeViewModel(),
);
