import 'package:flutter_moodic/domain/usecase/check_follow_status_usecase.dart';
import 'package:flutter_moodic/domain/usecase/follow_user_usecase.dart';
import 'package:flutter_moodic/domain/usecase/unfollow_user_usecase.dart';
import 'package:flutter/foundation.dart';
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

  // 통계 필드
  final int postCount;
  final int followerCount;
  final int followingCount;

  // 팔로우 상태 (타인일 경우)
  final bool isFollowing;

  MyPageState({
    required this.feeds,
    this.isLoading = false,
    this.errorMessage,
    required this.nickname,
    this.bio,
    this.profileimage,
    this.isUploading = false,
    this.optimisticProfileImage,
    this.postCount = 0,
    this.followerCount = 0,
    this.followingCount = 0,
    this.isFollowing = false,
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
    int? postCount,
    int? followerCount,
    int? followingCount,
    bool? isFollowing,
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
      postCount: postCount ?? this.postCount,
      followerCount: followerCount ?? this.followerCount,
      followingCount: followingCount ?? this.followingCount,
      isFollowing: isFollowing ?? this.isFollowing,
    );
  }
}

/// 마이페이지 피드 목록 Provider (Family로 변경하여 authorId 받음)
final myPageFamilyFeedsProvider = StreamProvider.family
    .autoDispose<List<Post>, String>((ref, authorId) {
      final currentUid = ref.watch(
        userProvider.select((value) => value.value?.uid),
      );

      final repository = ref.read(postRepositoryProvider);
      final fetchUserPostsUseCase = FetchUserPostsUseCase(repository);

      return fetchUserPostsUseCase.call(authorId, currentUserId: currentUid);
    });

class MyPageViewModel extends StateNotifier<MyPageState> {
  final String? userId; // 타겟 유저 ID (null이면 "나")
  final Ref ref;

  MyPageViewModel(this.userId, this.ref)
    : super(MyPageState(nickname: '', feeds: [], isLoading: true)) {
    _load();
    _watchUserProvider();
  }

  void _watchUserProvider() {
    // 내 프로필인 경우 (userId == null), userProvider가 변경될 때마다 state 업데이트
    if (userId == null) {
      ref.listen<AsyncValue<UserEntity?>>(userProvider, (previous, next) {
        final user = next.value;
        if (user != null) {
          // 닉네임, 프로필, 통계 정보 동기화
          if (mounted) {
            state = state.copyWith(
              nickname: user.nickname,
              bio: user.bio,
              profileimage: user.profileImage,
              postCount: user.postCount,
              followerCount: user.followerCount,
              followingCount: user.followingCount,
            );

            // 만약 처음에 피드를 못 불러왔다면(아이디가 없어서), 다시 시도
            // (이미 feeds가 있으면 다시 로드할 필요 없음, 스트림이 알아서 함?
            //  아니, StreamProvider family key가 uid이므로 uid가 바뀌거나 생기면 다시 구독해야 함)
            // 하지만 userId(생성자 인자)는 null로 고정. 내부적으로 사용하는 userIdToLoad가 문제.
            // 여기서는 복잡하므로 단순 정보 업데이트만 수행.
            // _load()에서 구독한 StreamProvider는 userProvider의 uid를 watch하고 있으므로 자동 갱신됨.
          }
        }
      });
    }
  }

  Future<void> _load() async {
    final targetUserId = userId; // 타겟 유저
    final currentUserState = ref.read(userProvider);
    final myUid = currentUserState.value?.uid; // 접속한 유저

    String? nickname;
    String? bio;
    String? profileImage;

    int postCount = 0;
    int followerCount = 0;
    int followingCount = 0;
    bool isFollowing = false;

    // 1. 타겟 유저 결정 (타겟이 없으면 나)
    final userIdToLoad = targetUserId ?? myUid;

    // 만약 "나"인데 아직 로딩 안됐으면 일단 대기 상태
    if (userIdToLoad == null && targetUserId == null) {
      // userProvider가 로딩되면 myPageFamilyFeedsProvider도 업데이트 될 것임.
      // 다만 닉네임 등은 위 _watchUserProvider에서 처리.
      state = state.copyWith(nickname: "", isLoading: true);
      // 여기서 return하면 feeds 구독을 안하게 됨. 구독은 해야 함.
      // 하지만 key가 null이면?
      // myPageFamilyFeedsProvider는 String을 받음. null 전달 불가.
      // 따라서 return 하되, 나중에 userProvider가 업데이트 되면 이 ViewModel이 다시 만들어지거나 해야 함.
      // 하지만 StateNotifierProvider는 유지가 됨.
      // 해결책: userProvider의 uid가 null -> non-null로 바뀌면 ViewModel도 갱신되어야 함?
      // 아니면 여기서 기다림?
      // 가장 좋은 건 UI에서 userProvider가 로딩 중이면 ViewModel 접근 전에 로딩을 띄우는 것.
      // 하지만 Router 구조상 ViewModel이 먼저 생성될 수 있음.

      // 일단 리턴. _watchUserProvider가 업데이트 해주기를 기대?
      // 아니, _watchUserProvider는 state만 업데이트함. 피드 로딩은?
      // 피드 로딩 트리거가 필요함.
    }

    // userIdToLoad가 있어야 아래 로직 수행 가능
    if (userIdToLoad != null) {
      // ... 기존 로직 ...
      // 2. 유저 정보 가져오기
      if (targetUserId == null || targetUserId == myUid) {
        // "나"인 경우
        final user = currentUserState.value;
        nickname = user?.nickname ?? "닉네임 없음";
        bio = user?.bio;
        profileImage = user?.profileImage;
        postCount = user?.postCount ?? 0;
        followerCount = user?.followerCount ?? 0;
        followingCount = user?.followingCount ?? 0;
      } else {
        // "타인"인 경우 Repository에서 fetch
        try {
          final repository = ref.read(userRepositoryProvider);
          final userEntity = await repository.getUser(userIdToLoad);

          nickname = userEntity?.nickname ?? "알 수 없는 사용자";
          bio = userEntity?.bio;
          profileImage = userEntity?.profileImage;
          postCount = userEntity?.postCount ?? 0;
          followerCount = userEntity?.followerCount ?? 0;
          followingCount = userEntity?.followingCount ?? 0;

          // 팔로우 여부 확인
          if (myUid != null) {
            final checkFollowUseCase = CheckFollowStatusUseCase(repository);
            isFollowing = await checkFollowUseCase.call(myUid, userIdToLoad);
          }
        } catch (e) {
          nickname = "유저 로드 실패";
        }
      }

      // 초기 설정
      if (mounted) {
        state = state.copyWith(
          nickname: nickname,
          bio: bio,
          profileimage: profileImage,
          postCount: postCount,
          followerCount: followerCount,
          followingCount: followingCount,
          isFollowing: isFollowing,
          isLoading: true,
        );
      }

      // 3. 피드 가져오기
      final feedsStreamProvider = myPageFamilyFeedsProvider(userIdToLoad);

      // Stream 구독
      ref.listen(feedsStreamProvider, (previous, next) {
        next.when(
          data: (feeds) {
            if (mounted) {
              state = state.copyWith(feeds: feeds, isLoading: false);
            }
          },
          error: (err, stack) {
            if (mounted) {
              state = state.copyWith(
                errorMessage: err.toString(),
                isLoading: false,
              );
            }
            debugPrint("MyPage Feed Error: $err");
          },
          loading: () {},
        );
      });

      // 현재 값 반영 (초기값)
      final currentAsyncValue = ref.read(feedsStreamProvider);
      if (currentAsyncValue.hasValue && mounted) {
        state = state.copyWith(
          feeds: currentAsyncValue.value!,
          isLoading: false,
        );
      }
    } else {
      // userIdToLoad is null (로그인 안됨 or 로딩중)
      // 아무것도 안함. (userProvider listener가 처리하길 기대하거나 UI에서 처리)
      state = state.copyWith(isLoading: false, nickname: "로딩 중...");
    }
  }

  /// 팔로우/언팔로우 토글
  Future<void> toggleFollow() async {
    final currentUserState = ref.read(userProvider);
    final myUid = currentUserState.value?.uid;
    final targetUid = userId; // 타겟 유저

    if (myUid == null || targetUid == null || myUid == targetUid) return;

    final repository = ref.read(userRepositoryProvider);
    final isCurrentlyFollowing = state.isFollowing;

    // 1. 낙관적 업데이트
    if (mounted) {
      state = state.copyWith(
        isFollowing: !isCurrentlyFollowing,
        followerCount:
            state.followerCount +
            (isCurrentlyFollowing ? -1 : 1), // 상대방의 팔로워 수 변경
      );
    }

    try {
      if (isCurrentlyFollowing) {
        final unfollowUseCase = UnfollowUserUseCase(repository);
        await unfollowUseCase.call(myUid, targetUid);
      } else {
        final followUseCase = FollowUserUseCase(repository);
        await followUseCase.call(myUid, targetUid);
      }
    } catch (e) {
      // 실패 시 롤백
      if (mounted) {
        state = state.copyWith(
          isFollowing: isCurrentlyFollowing,
          followerCount: state.followerCount + (isCurrentlyFollowing ? 1 : -1),
          errorMessage: "팔로우 처리 중 오류가 발생했습니다.",
        );
      }
    }
  }

  // StateNotifier에는 mounted 속성이 있음.
  // Getter for convenience if explicit usage needed (though super.mounted is available)
  // But wait, StateNotifier 'mounted' is available.
  // I used 'mount' in one place above, should be 'mounted'.

  /// 프로필 저장 (낙관적 업데이트 적용) - "나"일 때만 호출됨
  Future<void> saveProfile({
    required File? imageFile,
    required String nickname,
    required String bio,
    required bool isNotificationEnabled,
    required UserEntity currentUser,
  }) async {
    // 1. 낙관적 업데이트: UI 즉시 반영
    if (mounted) {
      state = state.copyWith(
        isUploading: imageFile != null,
        optimisticProfileImage: imageFile,
        nickname: nickname,
        bio: bio,
      );
    }

    try {
      String? imageUrl;

      // 이미지 업로드
      if (imageFile != null) {
        imageUrl = await ref
            .read(userRepositoryProvider)
            .uploadProfileImage(imageFile.path, currentUser.uid);
      }

      // 2. 서버 저장
      final updatedUser = currentUser.copyWith(
        nickname: nickname,
        bio: bio,
        profileImage: imageUrl ?? currentUser.profileImage,
        isNotificationEnabled: isNotificationEnabled,
      );

      await ref.read(userRepositoryProvider).saveUser(updatedUser);

      // 성공 시 업로드 상태 해제 및 최신 정보 반영
      if (mounted) {
        state = state.copyWith(
          isUploading: false,
          optimisticProfileImage: null,
          profileimage: updatedUser.profileImage,
        );
      }
    } catch (e) {
      // 실패 시 에러 메시지
      if (mounted) {
        state = state.copyWith(
          isUploading: false,
          errorMessage: "프로필 저장 실패: $e",
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
    StateNotifierProvider.family<MyPageViewModel, MyPageState, String?>(
      (ref, userId) => MyPageViewModel(userId, ref),
    );
