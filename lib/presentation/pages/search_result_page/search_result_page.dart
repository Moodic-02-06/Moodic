import 'package:flutter/material.dart';
import 'package:flutter_moodic/core/router/app_routers.dart';
import 'package:flutter_moodic/core/theme/app_color.dart';
import 'package:flutter_moodic/core/theme/fonts.dart';
import 'package:flutter_moodic/domain/entity/mood_type.dart';
import 'package:flutter_moodic/domain/entity/post.dart';
import 'package:flutter_moodic/presentation/pages/home_page/widgets/home_feed_card.dart';
import 'package:flutter_moodic/presentation/pages/search_result_page/search_result_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// 검색 결과 페이지
/// queryParameters로 type/value를 받아 mood 또는 music 검색 결과를 표시합니다.
/// - type=mood  : moodLabel로 감정 검색
/// - type=music : musicId, musicTitle, musicArtwork로 음악 검색
class SearchResultPage extends ConsumerStatefulWidget {
  /// type: 'mood' or 'music'
  final String type;

  /// mood 검색 시: mood label (예: '행복')
  /// music 검색 시: music id
  final String value;

  /// music 검색 시 표시용 제목 (optional)
  final String? musicTitle;

  /// music 검색 시 표시용 아트워크 URL (optional)
  final String? musicArtwork;

  const SearchResultPage({
    super.key,
    required this.type,
    required this.value,
    this.musicTitle,
    this.musicArtwork,
  }) : assert(type == 'mood' || type == 'music');

  @override
  ConsumerState<SearchResultPage> createState() => _SearchResultPageState();
}

class _SearchResultPageState extends ConsumerState<SearchResultPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = ref.read(searchResultViewModelProvider.notifier);
      if (widget.type == 'mood') {
        viewModel.loadByMood(widget.value);
      } else {
        viewModel.loadByMusicId(widget.value);
      }
    });
  }

  // 앱바 타이틀
  String get _title {
    if (widget.type == 'mood') {
      final mood = MoodType.fromLabel(widget.value);
      return '${mood.emoji} ${mood.label}';
    }
    return widget.musicTitle ?? '음악 검색';
  }

  String get _subtitle {
    if (widget.type == 'mood') return '이 감정의 게시글';
    return '이 음악이 담긴 게시글';
  }

  void _reload() {
    final viewModel = ref.read(searchResultViewModelProvider.notifier);
    if (widget.type == 'mood') {
      viewModel.loadByMood(widget.value);
    } else {
      viewModel.loadByMusicId(widget.value);
    }
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
            TextButton(onPressed: _reload, child: const Text('다시 시도')),
          ],
        ),
      );
    }

    if (state.posts.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async => _reload(),
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
    final isMood = widget.type == 'mood';
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isMood
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
            isMood
                ? '${widget.value} 감정의 첫 번째 게시글을 남겨보세요 ✨'
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

/// 게시글 카드 — postId만 전달해 DetailPage로 이동
class _SearchPostCard extends StatelessWidget {
  final Post post;

  const _SearchPostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.pushNamed(
          AppRoutes.DetailPage.name,
          pathParameters: {'id': post.postId},
        );
      },
      child: HomeFeedCard(post: post),
    );
  }
}
