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
                // 정렬 토글(헤더) + 피드 리스트
                itemCount: homeState.feeds.length + 1,
                separatorBuilder: (context, index) {
                  return const SizedBox(height: 16);
                },
                itemBuilder: (context, index) {
                  // 0번째 인덱스는 정렬 토글 (헤더)
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4, // 리스트 패딩 고려하여 약간 조정
                        vertical: 0,
                      ),
                      child: _AnimatedSortToggle(
                        sortType: homeState.sortType,
                        onTap: (type) {
                          if (homeState.sortType != type) {
                            homeVM.loadFeeds(newSort: type);
                          }
                        },
                      ),
                    );
                  }

                  // 1번째 인덱스부터 피드 데이터 (실제 데이터 인덱스는 index - 1)
                  final post = homeState.feeds[index - 1];
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

class _AnimatedSortToggle extends StatelessWidget {
  final FeedSortType sortType;
  final Function(FeedSortType) onTap;

  const _AnimatedSortToggle({required this.sortType, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const double height = 48;
    // 최신순(좌측) = -1.0, 인기순(우측) = 1.0
    final alignX = sortType == FeedSortType.latest ? -1.0 : 1.0;

    return Container(
      height: height + 8,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.primary600,
        borderRadius: BorderRadius.circular(61),
      ),
      child: Stack(
        children: [
          // 움직이는 배경 (Thumb)
          AnimatedAlign(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            alignment: Alignment(alignX, 0),
            child: FractionallySizedBox(
              widthFactor: 0.5,
              heightFactor: 1.0,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.primary900,
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // 2. 텍스트 버튼들 (Overlay)
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTap(FeedSortType.latest),
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 250),
                      style: AppTextStyles.bodyPrimary16w600.copyWith(
                        color: sortType == FeedSortType.latest
                            ? AppColors.text900
                            : AppColors.gray500,
                      ),
                      child: const Text('최신 글'),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTap(FeedSortType.mostLiked),
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 250),
                      style: AppTextStyles.bodyPrimary16w600.copyWith(
                        color: sortType == FeedSortType.mostLiked
                            ? AppColors.text900
                            : AppColors.gray500,
                      ),
                      child: const Text('인기 글'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
