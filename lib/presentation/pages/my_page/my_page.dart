import 'package:flutter/material.dart';
import 'package:flutter_moodic/core/theme/app_color.dart';
import 'package:flutter_moodic/core/theme/fonts.dart';
import 'package:flutter_moodic/presentation/pages/my_page/widgets/emotion_graph.dart';
import 'package:flutter_moodic/presentation/pages/my_page/my_page_viewmodel.dart';
import 'package:flutter_moodic/presentation/pages/my_page/widgets/grid_view.dart';
import 'package:flutter_moodic/core/router/app_routers.dart';
import 'package:flutter_moodic/presentation/provider/user_provider.dart';
import 'package:go_router/go_router.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyPage extends ConsumerWidget {
  final String? userId; // 타 유저 ID (null이면 내 프로필)

  const MyPage({super.key, this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // userId가 있거나, 없으면 내 ID
    final currentUser = ref.watch(userProvider).value;
    final targetUserId = userId ?? currentUser?.uid;
    final isMe = (userId == null) || (userId == currentUser?.uid);

    // Family Provider 구독
    final myPageState = ref.watch(myPageViewModelProvider(userId));

    // 로딩 중이고 데이터가 없으면 로딩 표시
    if (myPageState.isLoading &&
        myPageState.feeds.isEmpty &&
        myPageState.nickname.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // 에러 있고 데이터 없으면 에러 표시
    if (myPageState.errorMessage != null && myPageState.feeds.isEmpty) {
      return Center(child: Text("에러 발생: ${myPageState.errorMessage}"));
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "프로필",
          style: AppTextStyles.titlePrimary20w600.copyWith(
            color: AppColors.text900,
          ),
        ),
        actions: [
          // 내 프로필일 때만 수정 버튼 노출
          if (isMe)
            IconButton(
              onPressed: () {
                context.pushNamed(AppRoutes.MyPageEdit.name);
              },
              icon: const Icon(Icons.settings_outlined),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 프로필 이미지
            // 닉네임, 소개
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.gray400, width: 1.5),
                  ),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.primary900,
                    backgroundImage:
                        (myPageState.profileimage != null &&
                            myPageState.profileimage!.isNotEmpty)
                        ? NetworkImage(myPageState.profileimage!)
                        : null,
                    child: myPageState.isUploading
                        ? const CircularProgressIndicator()
                        : (myPageState.profileimage == null ||
                              myPageState.profileimage!.isEmpty)
                        ? Icon(Icons.person, color: AppColors.gray100, size: 80)
                        : null,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        myPageState.nickname,
                        style: AppTextStyles.titlePrimary20w600.copyWith(
                          color: AppColors.text900,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        myPageState.bio ?? '',
                        style: AppTextStyles.bodyPrimary16w600.copyWith(
                          color: AppColors.text900,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            // 팔로잉/팔로워/게시글 통계 (순서 변경: 게시글, 팔로워, 팔로잉)
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    "게시글",
                    myPageState.postCount,
                    null,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    "팔로워",
                    myPageState.followerCount,
                    () {
                      context.pushNamed(
                        AppRoutes.FollowList.name,
                        pathParameters: {
                          'userId': targetUserId ?? currentUser?.uid ?? '',
                        },
                        queryParameters: {'initialTab': '0'},
                      );
                    },
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    "팔로잉",
                    myPageState.followingCount,
                    () {
                      context.pushNamed(
                        AppRoutes.FollowList.name,
                        pathParameters: {
                          'userId': targetUserId ?? currentUser?.uid ?? '',
                        },
                        queryParameters: {'initialTab': '1'},
                      );
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),

            // 팔로우/언팔로우 버튼 (타인일 경우에만 표시)
            if (!isMe) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ref
                        .read(myPageViewModelProvider(userId).notifier)
                        .toggleFollow();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: myPageState.isFollowing
                        ? AppColors.gray100
                        : AppColors.primary900,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    myPageState.isFollowing ? "팔로잉" : "팔로우",
                    style: AppTextStyles.bodyPrimary16w600.copyWith(
                      color: myPageState.isFollowing
                          ? AppColors.text900
                          : Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24),
            ],

            // 감정 그래프 (타겟 유저 ID 전달)
            if (targetUserId != null) ...[
              Text(
                "${DateTime.now().year % 100}.${DateTime.now().month.toString().padLeft(2, '0')} 감정 그래프",
                style: AppTextStyles.bodyPrimary16w500.copyWith(
                  color: AppColors.gray900,
                ),
              ),
              SizedBox(height: 12),
              EmotionGraph(userId: targetUserId),
              SizedBox(height: 12),
            ],

            // 그리드 뷰
            MyPageGridView(userId: userId),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    int count,
    VoidCallback? onTap,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              Text(
                count.toString(),
                style: AppTextStyles.titlePrimary20w600.copyWith(
                  color: AppColors.text900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: AppTextStyles.bodyPrimary16w500.copyWith(
                  color: AppColors.gray500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
