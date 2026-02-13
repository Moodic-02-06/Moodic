import 'package:flutter_moodic/domain/entity/post.dart';
import 'package:flutter_moodic/domain/usecase/fetch_feeds_usecase.dart';
import 'package:flutter_moodic/presentation/provider/repository_provider.dart';
import 'package:flutter_moodic/presentation/provider/user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_moodic/domain/entity/mood_type.dart';

class MyPageState {
  final String nickname;
  final String? bio;
  final String? profileimage;
  final List<Post> feeds;
  final bool isLoading;
  final String? errorMessage;

  MyPageState({
    required this.feeds,
    this.isLoading = false,
    this.errorMessage,
    required this.nickname,
    this.bio,
    this.profileimage,
  });

  MyPageState copyWith({
    String? nickname,
    String? bio,
    String? profileimage,
    List<Post>? feeds,
    bool? isLoading,
    String? errorMessage,
  }) {
    return MyPageState(
      nickname: nickname ?? this.nickname,
      bio: bio ?? this.bio,
      profileimage: profileimage ?? this.profileimage,
      feeds: feeds ?? this.feeds,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class MyPageViewModel extends AsyncNotifier<MyPageState> {
  @override
  Future<MyPageState> build() async {
    final userState = ref.watch(userProvider);
    final repository = ref.read(postRepositoryProvider);
    final fetchFeedsUseCase = FetchFeedsUseCase(repository);
    var fetchedFeeds = await fetchFeedsUseCase.call(
      limit: 50,
      userId: userState.value?.uid,
    );

    return MyPageState(
      nickname: userState.value?.nickname ?? "닉네임을 알수없음",
      bio: userState.value?.bio,
      profileimage: userState.value?.profileImage,
      feeds: fetchedFeeds,
    );
  }
}

/// 월별 감정 통계 Provider (Family로 userId 받음)
final monthlyMoodsProvider = FutureProvider.family<Map<MoodType, int>, String>((
  ref,
  userId,
) async {
  final repository = ref.read(postRepositoryProvider);
  final now = DateTime.now();
  final posts = await repository.fetchPostsByMonth(userId, now.year, now.month);

  final Map<MoodType, int> counts = {};

  // 초기화
  for (var mood in MoodType.values) {
    counts[mood] = 0;
  }

  // 카운팅
  for (var post in posts) {
    try {
      final moodEnum = MoodType.values.firstWhere(
        (m) => m.label == post.mood || m.name == post.mood,
        orElse: () => MoodType.happy,
      );
      counts[moodEnum] = (counts[moodEnum] ?? 0) + 1;
    } catch (e) {
      // ignore
    }
  }

  return counts;
});

final myPageViewModelProvider =
    AsyncNotifierProvider<MyPageViewModel, MyPageState>(() {
      return MyPageViewModel();
    });
