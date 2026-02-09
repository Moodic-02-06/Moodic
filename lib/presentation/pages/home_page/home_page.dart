import 'package:flutter/material.dart';
import 'package:flutter_moodic/core/theme/app_color.dart';
import 'package:flutter_moodic/core/theme/fonts.dart';
import 'package:flutter_moodic/presentation/pages/home_page/home_view_model.dart';
import 'package:flutter_moodic/presentation/pages/home_page/widgets/home_post_card.dart';
import 'package:flutter_moodic/presentation/pages/write_page/write_page.dart';
import 'package:flutter_moodic/presentation/widgets/custom_bottom_nav_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeViewModelProvider);
    final homeVM = ref.read(homeViewModelProvider.notifier);

    // 화면 빌드 시 한 번만 피드 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (homeState.feeds.isEmpty && !homeState.isLoading) {
        homeVM.loadFeeds();
      }
    });

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Image.asset('assets/images/logo.png', width: 70),
      ),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: 0,
        onTap: (index) {},
      ),
      body: homeState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : homeState.errorMessage != null
          ? Center(
              child: Text(
                '오류가 발생했습니다.\n${homeState.errorMessage}',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
            )
          : homeState.feeds.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 안내 메시지
                    Text(
                      '아직 작성된 피드가 없어요.\n첫 글을 작성해보세요!',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyPrimary16w600.copyWith(
                        color: AppColors.gray500,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // 새 글 작성 버튼
                    ElevatedButton.icon(
                      onPressed: () {
                        // 새 글 작성 화면으로 이동
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return const WritePage();
                            },
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('새 글 작성'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
              ).copyWith(bottom: 120),
              itemCount: homeState.feeds.length,
              separatorBuilder: (context, index) {
                return const SizedBox(height: 16);
              },
              itemBuilder: (context, index) {
                final post = homeState.feeds[index];
                return HomeFeedCard(
                  post: post,
                  onLikeToggle: (userId) => homeVM.toggleLike(post, userId),
                );
              },
            ),
    );
  }
}
