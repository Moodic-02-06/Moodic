import 'package:flutter/material.dart';
import 'package:flutter_moodic/core/router/app_routers.dart';
import 'package:flutter_moodic/core/theme/app_color.dart';
import 'package:flutter_moodic/core/theme/fonts.dart';
import 'package:flutter_moodic/domain/entity/mood_type.dart';
import 'package:flutter_moodic/domain/entity/music.dart';
import 'package:flutter_moodic/domain/entity/post.dart';
import 'package:flutter_moodic/presentation/pages/home_page/widgets/home_feed_card.dart';
import 'package:flutter_moodic/presentation/pages/search_result_page/search_result_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 검색 결과 페이지
/// [extra]로 MoodType 또는 Music 객체를 받음
class SearchResultPage extends ConsumerStatefulWidget {
  /// MoodType 검색일 때 사용
  final MoodType? mood;

  /// Music 검색일 때 사용
  final Music? music;

  const SearchResultPage({super.key, this.mood, this.music})
    : assert(
        mood != null || music != null,
        'mood 또는 music 중 하나는 반드시 전달해야 합니다.',
      );

  @override
  ConsumerState<SearchResultPage> createState() => _SearchResultPageState();
}

class _SearchResultPageState extends ConsumerState<SearchResultPage> {
  @override
  void initState() {
    super.initState();
    // 진입 직후 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = ref.read(searchResultViewModelProvider.notifier);
      if (widget.mood != null) {
        viewModel.loadByMood(widget.mood!.label);
      } else if (widget.music != null) {
        viewModel.loadByMusicId(widget.music!.id);
      }
    });
  }

  String get _title {
    if (widget.mood != null) {
      return '${widget.mood!.emoji} ${widget.mood!.label}';
    }
    if (widget.music != null) {
      return widget.music!.title;
    }
    return '검색 결과';
  }

  String get _subtitle {
    if (widget.mood != null) return '이 감정의 게시글';
    if (widget.music != null) return '이 음악이 담긴 게시글';
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchResultViewModelProvider);

    return Scaffold(
      backgroundColor: AppColors.primary700,
      appBar: AppBar(
        backgroundColor: AppColors.primary700,
        scrolledUnderElevation: 0,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.text900),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _title,
              style: AppTextStyles.titlePrimary20w600.copyWith(
                color: AppColors.text900,
              ),
            ),
            if (_subtitle.isNotEmpty)
              Text(
                _subtitle,
                style: AppTextStyles.labelStatus12w500.copyWith(
                  color: AppColors.gray500,
                ),
              ),
          ],
        ),
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(SearchResultState state) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.secondary600),
      );
    }

    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.gray300),
            const SizedBox(height: 16),
            Text(
              '불러오기에 실패했어요',
              style: AppTextStyles.bodyPrimary16w500.copyWith(
                color: AppColors.gray300,
              ),
            ),
            const SizedBox(height: 8),
            // 디버깅용 에러 메시지 표시
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                state.error!,
                style: AppTextStyles.labelStatus12w500.copyWith(
                  color: AppColors.gray300,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                final viewModel = ref.read(
                  searchResultViewModelProvider.notifier,
                );
                if (widget.mood != null) {
                  viewModel.loadByMood(widget.mood!.label);
                } else if (widget.music != null) {
                  viewModel.loadByMusicId(widget.music!.id);
                }
              },
              child: const Text('다시 시도'),
            ),
          ],
        ),
      );
    }

    if (state.posts.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        final viewModel = ref.read(searchResultViewModelProvider.notifier);
        if (widget.mood != null) {
          await viewModel.loadByMood(widget.mood!.label);
        } else if (widget.music != null) {
          await viewModel.loadByMusicId(widget.music!.id);
        }
      },
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        itemCount: state.posts.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final post = state.posts[index];
          return _SearchPostCard(post: post);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            widget.mood != null
                ? Icons.sentiment_dissatisfied_rounded
                : Icons.music_off_rounded,
            size: 64,
            color: AppColors.gray300,
          ),
          const SizedBox(height: 16),
          Text(
            '아직 게시글이 없어요',
            style: AppTextStyles.bodyPrimary16w500.copyWith(
              color: AppColors.gray500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.mood != null
                ? '${widget.mood!.label} 감정의 첫 번째 게시글을 남겨보세요 ✨'
                : '이 음악으로 일기를 써보세요 🎵',
            style: AppTextStyles.labelStatus12w500.copyWith(
              color: AppColors.gray300,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// 게시글 카드 (탭 시 디테일 페이지로 이동)
class _SearchPostCard extends StatelessWidget {
  final Post post;

  const _SearchPostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push(AppRoutes.DetailPage.absolutePath, extra: post);
      },
      child: HomeFeedCard(post: post),
    );
  }
}
