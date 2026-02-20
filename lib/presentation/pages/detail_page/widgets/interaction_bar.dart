import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 햅틱 피드백을 위해 추가
import 'package:flutter_moodic/core/theme/app_color.dart';
import 'package:flutter_moodic/core/theme/fonts.dart';
import 'package:flutter_moodic/domain/entity/post.dart';
import 'package:flutter_moodic/presentation/pages/detail_page/detail_view_model.dart';
import 'package:flutter_moodic/presentation/provider/user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InteractionBar extends ConsumerWidget {
  final Post post;

  const InteractionBar({super.key, required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        _AnimatedLikeButton(
          isLiked: post.isLikedByMe,
          likeCount: post.likeCount,
          onTap: () {
            // 1. 유저 정보 가져오기
            final currentUser = ref.read(userProvider).value;

            if (currentUser != null) {
              // 2. ViewModel의 toggleLike 호출
              ref
                  .read(detailViewModelProvider(post.postId).notifier)
                  .toggleLike(currentUser);
            } else {
              // 로그인 안 된 경우 안내
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('로그인이 필요한 서비스입니다.')));
            }
          },
        ),

        const SizedBox(width: 12),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.chat_bubble_outline,
                color: AppColors.gray500,
                size: 28,
              ),
              const SizedBox(width: 6),
              Text(
                '${post.commentCount}',
                style: AppTextStyles.bodyPrimary16w600.copyWith(
                  color: AppColors.gray500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AnimatedLikeButton extends StatefulWidget {
  final bool isLiked;
  final int likeCount;
  final VoidCallback onTap;

  const _AnimatedLikeButton({
    required this.isLiked,
    required this.likeCount,
    required this.onTap,
  });

  @override
  State<_AnimatedLikeButton> createState() => _AnimatedLikeButtonState();
}

class _AnimatedLikeButtonState extends State<_AnimatedLikeButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150), // 빠른 반응성
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 1.4,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.4,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.bounceIn)),
        weight: 50,
      ),
    ]).animate(_controller);
  }

  @override
  void didUpdateWidget(_AnimatedLikeButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 좋아요 상태가 비활성 -> 활성으로 변할 때만 애니메이션 실행
    if (widget.isLiked && !oldWidget.isLiked) {
      _controller.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        // 1. 햅틱 피드백 발생
        await HapticFeedback.lightImpact();
        // 2. 상위 콜백 실행
        widget.onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ScaleTransition(
              scale: _scaleAnimation,
              child: Icon(
                widget.isLiked ? Icons.favorite : Icons.favorite_border,
                color: widget.isLiked
                    ? const Color.fromARGB(255, 224, 81, 71)
                    : AppColors.gray500,
                size: 28,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${widget.likeCount}',
              style: AppTextStyles.bodyPrimary16w600.copyWith(
                color: AppColors.gray500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
