import 'package:flutter/material.dart';
import 'package:flutter_moodic/core/router/app_routers.dart';
import 'package:flutter_moodic/core/theme/app_color.dart';
import 'package:flutter_moodic/core/theme/fonts.dart';

import 'package:flutter_moodic/presentation/pages/home_page/home_view_model.dart';
import 'package:flutter_moodic/presentation/pages/home_page/widgets/home_feed_card.dart';
import 'package:flutter_moodic/presentation/pages/write_page/write_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // 화면 진입 시 최초 1회만 실행
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(homeViewModelProvider.notifier).loadFeeds();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final homeState = ref.read(homeViewModelProvider);
      if (!homeState.isLoading) {
        ref.read(homeViewModelProvider.notifier).loadMore();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeViewModelProvider);
    final homeVM = ref.read(homeViewModelProvider.notifier);

    // 1. 초기 로딩 중이고 데이터가 없는 경우 -> 전체 로딩
    if (homeState.isLoading && homeState.feeds.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // 2. 에러가 있고 데이터가 없는 경우 -> 에러 화면
    if (homeState.errorMessage != null && homeState.feeds.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Image.asset('assets/images/logo.png', width: 70),
        ),
        body: Center(
          child: Text(
            '오류가 발생했습니다.\n${homeState.errorMessage}',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.stateError, fontSize: 16),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Image.asset('assets/images/logo.png', width: 70),
      ),
      body: homeState.feeds.isEmpty
          ? RefreshIndicator(
              onRefresh: () => homeVM.refresh(),
              child: Stack(
                children: [
                  ListView(), // 빈 리스트뷰 (RefreshIndicator 동작용)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '아직 작성된 피드가 없어요.\n첫 글을 작성해보세요!',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodyPrimary16w600.copyWith(
                              color: AppColors.gray500,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const WritePage(),
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
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () => homeVM.refresh(),
              child: ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.all(12).copyWith(bottom: 120),
                // 로딩 인디케이터를 위해 +1
                itemCount: homeState.feeds.length,
                separatorBuilder: (context, index) {
                  return const SizedBox(height: 16);
                },
                itemBuilder: (context, index) {
                  final post = homeState.feeds[index];
                  return GestureDetector(
                    onTap: () {
                      context.pushNamed(
                        AppRoutes.DetailPage.name,
                        pathParameters: {'id': post.postId},
                        extra: post,
                      );
                    },
                    child: HomeFeedCard(post: post),
                  );
                },
              ),
            ),
    );
  }
}
