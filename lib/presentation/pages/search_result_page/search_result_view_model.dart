import 'package:flutter/foundation.dart';
import 'package:flutter_moodic/domain/entity/post.dart';
import 'package:flutter_moodic/presentation/provider/use_case_provider.dart';
import 'package:flutter_moodic/presentation/provider/user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SearchResultState {
  final List<Post> posts;
  final bool isLoading;
  final String? error;

  const SearchResultState({
    this.posts = const [],
    this.isLoading = false,
    this.error,
  });

  SearchResultState copyWith({
    List<Post>? posts,
    bool? isLoading,
    String? error,
  }) {
    return SearchResultState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class SearchResultViewModel extends AutoDisposeNotifier<SearchResultState> {
  @override
  SearchResultState build() {
    return const SearchResultState(isLoading: true);
  }

  String? get _currentUserId => ref.read(userProvider).value?.uid;

  Future<void> loadByMood(String mood) async {
    state = const SearchResultState(isLoading: true);
    try {
      final posts = await ref
          .read(searchByMoodUseCaseProvider)
          .call(mood, _currentUserId);
      state = SearchResultState(posts: posts);
    } catch (e) {
      debugPrint('기분 검색 실패: $e');
      state = SearchResultState(error: e.toString());
    }
  }

  Future<void> loadByMusicId(String musicId) async {
    state = const SearchResultState(isLoading: true);
    try {
      final posts = await ref
          .read(searchByMusicIdUseCaseProvider)
          .call(musicId, _currentUserId);
      state = SearchResultState(posts: posts);
    } catch (e) {
      debugPrint('음악 검색 실패: $e');
      state = SearchResultState(error: e.toString());
    }
  }
}

final searchResultViewModelProvider =
    NotifierProvider.autoDispose<SearchResultViewModel, SearchResultState>(
      SearchResultViewModel.new,
    );
