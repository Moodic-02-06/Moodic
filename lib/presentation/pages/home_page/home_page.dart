import 'package:flutter/material.dart';
import 'package:flutter_moodic/core/router/app_routers.dart';
import 'package:flutter_moodic/core/theme/app_color.dart';

import 'package:flutter_moodic/presentation/pages/home_page/home_view_model.dart';
import 'package:flutter_moodic/presentation/pages/home_page/widgets/home_empty_state.dart';
import 'package:flutter_moodic/presentation/pages/home_page/widgets/home_feed_card.dart';
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

    // 1. 초기 로딩 중이고 데이터가 없는 경우 → 전체 로딩
    if (homeState.isLoading && homeState.feeds.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // 2. 에러가 있고 데이터가 없는 경우 → 에러 화면
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
          ? HomeEmptyState(onRefresh: () => homeVM.refresh())
          : RefreshIndicator(
              onRefresh: () => homeVM.refresh(),
              child: ListView.separated(
                controller: _scrollController,
                padding: const EdgeInsets.all(12).copyWith(bottom: 120),
                itemCount: homeState.feeds.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
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
