import 'package:flutter_moodic/domain/entity/post.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_moodic/domain/entity/mood_type.dart';
import 'package:flutter_moodic/presentation/pages/write_page/post_repository_provider.dart';

class MyPageState {
  final List<Post> feeds;
  final bool isLoading;
  final String? errorMessage;

  MyPageState({required this.feeds, this.isLoading = false, this.errorMessage});

  MyPageState copyWith({
    List<Post>? feeds,
    bool? isLoading,
    String? errorMessage,
  }) {
    return MyPageState(
      feeds: feeds ?? this.feeds,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class MyPageViewmodel extends Notifier<MyPageState> {
  @override
  MyPageState build() {
    return MyPageState(feeds: []);
  }
}

final myPageViewModelProvider = NotifierProvider<MyPageViewmodel, MyPageState>(
  MyPageViewmodel.new,
);

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
