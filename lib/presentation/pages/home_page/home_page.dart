import 'package:flutter/material.dart';
import 'package:flutter_moodic/core/theme/app_color.dart';
import 'package:flutter_moodic/core/theme/fonts.dart';
import 'package:flutter_moodic/presentation/pages/detail_page/detail_page.dart';
import 'package:flutter_moodic/presentation/pages/home_page/home_view_model.dart';
import 'package:flutter_moodic/presentation/pages/home_page/widgets/home_post_card.dart';
import 'package:flutter_moodic/presentation/pages/write_page/write_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    // 화면 진입 시 최초 1회만 실행
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(homeViewModelProvider.notifier).loadFeeds();
    });
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeViewModelProvider);
    final homeVM = ref.read(homeViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Image.asset('assets/images/logo.png', width: 70),
      ),

      body: homeState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : homeState.errorMessage != null
          ? Center(
              child: Text(
                '오류가 발생했습니다.\n${homeState.errorMessage}',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.stateError, fontSize: 16),
              ),
            )
          : homeState.feeds.isEmpty
          ? RefreshIndicator(
              onRefresh: () => homeVM.loadFeeds(),
              child: Center(
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
              ),
            )

          : RefreshIndicator(
              onRefresh: () => homeVM.loadFeeds(),
              child: ListView.separated(
                padding: const EdgeInsets.all(12).copyWith(bottom: 120),
                itemCount: homeState.feeds.length,
                separatorBuilder: (context, index) {
                  return const SizedBox(height: 16);
                },
               itemBuilder: (context, index) {
                final post = homeState.feeds[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) {
                          return DetailPage();
                        },
                      ),
                    );
                  },
              ),

            ),
    );
  }
}
