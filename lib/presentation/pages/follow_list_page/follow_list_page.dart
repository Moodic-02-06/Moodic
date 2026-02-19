import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_moodic/core/theme/app_color.dart';
import 'package:flutter_moodic/core/theme/fonts.dart';
import 'package:flutter_moodic/domain/entity/user_entity.dart';
import 'package:flutter_moodic/presentation/pages/follow_list_page/follow_list_view_model.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_moodic/core/router/app_routers.dart';
import 'package:flutter_moodic/presentation/provider/user_provider.dart';

class FollowListPage extends ConsumerStatefulWidget {
  final String userId;
  final int initialTabIndex; // 0: 팔로워, 1: 팔로잉

  const FollowListPage({
    super.key,
    required this.userId,
    this.initialTabIndex = 0,
  });

  @override
  ConsumerState<FollowListPage> createState() => _FollowListPageState();
}

class _FollowListPageState extends ConsumerState<FollowListPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTabIndex,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(followListViewModelProvider(widget.userId));
    final viewModel = ref.read(
      followListViewModelProvider(widget.userId).notifier,
    );
    final currentUser = ref.watch(userProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Follow List", // 닉네임을 표시하면 더 좋음
          style: AppTextStyles.titlePrimary20w600.copyWith(
            color: AppColors.text900,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.text900,
          unselectedLabelColor: AppColors.gray500,
          indicatorColor: AppColors.primary900,
          tabs: [
            Tab(text: "팔로워"),
            Tab(text: "팔로잉"),
          ],
        ),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildUserList(
                  state.followers,
                  state.myFollowingIds,
                  viewModel,
                  currentUser?.uid,
                ),
                _buildUserList(
                  state.following,
                  state.myFollowingIds,
                  viewModel,
                  currentUser?.uid,
                ),
              ],
            ),
    );
  }

  Widget _buildUserList(
    List<UserEntity> users,
    Set<String> myFollowingIds,
    FollowListViewModel viewModel,
    String? currentUserId,
  ) {
    if (users.isEmpty) {
      return Center(
        child: Text(
          "유저가 없습니다.",
          style: AppTextStyles.bodyPrimary16w500.copyWith(
            color: AppColors.gray500,
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        final isMe = user.uid == currentUserId;
        final isFollowing = myFollowingIds.contains(user.uid);

        return ListTile(
          leading: GestureDetector(
            onTap: () {
              // 프로필로 이동
              context.pushNamed(
                AppRoutes.MyPage.name,
                pathParameters: {'userId': user.uid},
              );
            },
            child: CircleAvatar(
              backgroundImage:
                  (user.profileImage != null && user.profileImage!.isNotEmpty)
                  ? NetworkImage(user.profileImage!)
                  : null,
              child: (user.profileImage == null || user.profileImage!.isEmpty)
                  ? const Icon(Icons.person, color: AppColors.gray100)
                  : null,
            ),
          ),
          title: Text(user.nickname, style: AppTextStyles.bodyPrimary16w600),
          trailing: isMe
              ? null // 나 자신이면 버튼 없음
              : TextButton(
                  onPressed: () => viewModel.toggleFollow(user.uid),
                  style: TextButton.styleFrom(
                    backgroundColor: isFollowing
                        ? AppColors.gray100
                        : AppColors.primary900,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    isFollowing ? "팔로잉" : "팔로우",
                    style: AppTextStyles.bodyPrimary14w600.copyWith(
                      color: isFollowing ? AppColors.text900 : Colors.white,
                    ),
                  ),
                ),
          onTap: () {
            context.pushNamed(
              AppRoutes.MyPage.name,
              pathParameters: {'userId': user.uid},
            );
          },
        );
      },
    );
  }
}
