import 'package:flutter_moodic/data/repository/user_repository_impl.dart';
import 'package:flutter_moodic/domain/entity/post.dart';
import 'package:flutter_moodic/domain/entity/user_entity.dart';
import 'package:flutter_moodic/domain/usecase/fetch_user_posts_usecase.dart';
import 'package:flutter_moodic/presentation/provider/repository_provider.dart';
import 'package:flutter_moodic/presentation/provider/user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_moodic/domain/entity/mood_type.dart';
import 'dart:io';

class MyPageState {
  final String nickname;
  final String? bio;
  final String? profileimage;
  final List<Post> feeds;
  final bool isLoading;
  final String? errorMessage;

  // 낙관적 업데이트를 위한 필드 추가
  final bool isUploading;
  final File? optimisticProfileImage;

  MyPageState({
    required this.feeds,
    this.isLoading = false,
    this.errorMessage,
    required this.nickname,
    this.bio,
    this.profileimage,
    this.isUploading = false,
    this.optimisticProfileImage,
  });

  MyPageState copyWith({
    String? nickname,
    String? bio,
    String? profileimage,
    List<Post>? feeds,
    bool? isLoading,
    String? errorMessage,
    bool? isUploading,
    File? optimisticProfileImage,
  }) {
    return MyPageState(
      nickname: nickname ?? this.nickname,
      bio: bio ?? this.bio,
      profileimage: profileimage ?? this.profileimage,
      feeds: feeds ?? this.feeds,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      isUploading: isUploading ?? this.isUploading,
      optimisticProfileImage:
          optimisticProfileImage ?? this.optimisticProfileImage,
    );
  }
}

/// 마이페이지 피드 목록 Provider (UserUID 기반)
/// StreamProvider로 변경하여 실시간 업데이트 지원
final myPageFeedsProvider = StreamProvider.autoDispose<List<Post>>((ref) {
  // UserProvider의 전체 상태를 구독하지 않고, UID만 구독하여 최적화
  final uid = ref.watch(userProvider.select((value) => value.value?.uid));

  if (uid == null) return Stream.value([]);

  final repository = ref.read(postRepositoryProvider);
  final fetchUserPostsUseCase = FetchUserPostsUseCase(repository);

  // await 없이 Stream 반환
  return fetchUserPostsUseCase.call(uid);
});

class MyPageViewModel extends AsyncNotifier<MyPageState> {
  @override
  Future<MyPageState> build() async {
    final userState = ref.watch(userProvider);
    // 피드 Provider 구독 (값이 변경되면 MyPageViewModel도 Rebuild 됨)
    final feedsAsync = ref.watch(myPageFeedsProvider);

    // 피드 로딩 중이거나 에러가 있어도, MyPage 자체는 보여주기 위해 빈 리스트 또는 기존 데이터 처리
    // 여기서는 feedsAsync.value를 사용하여 데이터가 있으면 사용하고, 없으면 빈 리스트
    final feeds = feedsAsync.value ?? [];

    return MyPageState(
      nickname: userState.value?.nickname ?? "닉네임을 알수없음",
      bio: userState.value?.bio,
      profileimage: userState.value?.profileImage,
      feeds: feeds,
    );
  }

  /// 프로필 저장 (낙관적 업데이트 적용)
  Future<void> saveProfile({
    required File? imageFile,
    required String nickname,
    required String bio,
    required UserEntity currentUser,
  }) async {
    // 1. 낙관적 업데이트: UI 즉시 반영
    state = AsyncData(
      state.value!.copyWith(
        isUploading: imageFile != null, // 이미지가 변경된 경우에만 로딩 표시
        optimisticProfileImage: imageFile,
        nickname: nickname,
        bio: bio,
      ),
    );

    try {
      String? imageUrl = currentUser.profileImage;

      // 2. 이미지 업로드 (변경된 경우)
      if (imageFile != null) {
        imageUrl = await ref
            .read(userRepositoryProvider)
            .uploadProfileImage(imageFile.path, currentUser.uid);
      }

      // 3. 유저 정보 업데이트
      final updatedUser = currentUser.copyWith(
        nickname: nickname,
        bio: bio,
        profileImage: imageUrl,
      );

      await ref.read(userRepositoryProvider).updateUser(updatedUser);

      // 성공 시: userProvider가 자동으로 최신 데이터를 가져오므로
      // 별도의 state 갱신 없이 build가 다시 호출되어 isUploading이 false가 된 상태로 돌아올 것임.
    } catch (e) {
      // 실패 시: 에러 메시지 설정 및 로딩 상태 해제, 원래 값으로 복구는 복잡하므로 에러만 표시
      if (state.hasValue) {
        state = AsyncData(
          state.value!.copyWith(
            isUploading: false,
            errorMessage: "프로필 저장 실패: $e",
          ),
        );
      }
    }
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
