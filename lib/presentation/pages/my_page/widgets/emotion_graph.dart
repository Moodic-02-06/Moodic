import 'package:flutter/material.dart';
import 'package:flutter_moodic/core/theme/app_color.dart';
import 'package:flutter_moodic/core/theme/fonts.dart';
import 'package:flutter_moodic/domain/entity/mood_type.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_moodic/presentation/pages/my_page/my_page_viewmodel.dart';

class EmotionGraph extends ConsumerWidget {
  final String? userId;
  const EmotionGraph({super.key, this.userId});

  double _calculateHeight(int count) {
    if (count == 0) return 40.0; // 최소 높이
    double height = 50.0 + (count - 1) * 2.5;
    if (height > 130.0) height = 130.0; // 최대 높이 제한
    return height;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // userId가 넘어오면 그것을 쓰고, 아니면 내 정보를 쓴다.
    // 하지만 상위에서 이미 로직을 처리해서 userId를 넘겨주는 것이 더 깔끔할 수 있다.
    // 여기서는 MyPage에서 넘겨준 targetUserId를 사용한다.

    // targetUserId가 null이면 (즉, 로그인도 안된 상태 등) 빈 공간
    if (userId == null) {
      return const SizedBox(height: 171); // 유저 정보 없을 때 빈 공간
    }

    final moodAsyncValue = ref.watch(monthlyMoodsProvider(userId!));

    return Container(
      width: double.infinity,
      height: 171,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColors.primary600,
      ),
      child: moodAsyncValue.when(
        data: (counts) => Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Emotion(
              emoji: MoodType.happy.emoji,
              height: _calculateHeight(counts[MoodType.happy] ?? 0).toInt(),
              label: MoodType.happy.label,
              mood: MoodType.happy,
              count: counts[MoodType.happy] ?? 0,
            ),
            Emotion(
              emoji: MoodType.sad.emoji,
              height: _calculateHeight(counts[MoodType.sad] ?? 0).toInt(),
              label: MoodType.sad.label,
              mood: MoodType.sad,
              count: counts[MoodType.sad] ?? 0,
            ),
            Emotion(
              emoji: MoodType.angry.emoji,
              height: _calculateHeight(counts[MoodType.angry] ?? 0).toInt(),
              label: MoodType.angry.label,
              mood: MoodType.angry,
              count: counts[MoodType.angry] ?? 0,
            ),
            Emotion(
              emoji: MoodType.calm.emoji,
              height: _calculateHeight(counts[MoodType.calm] ?? 0).toInt(),
              label: MoodType.calm.label,
              mood: MoodType.calm,
              count: counts[MoodType.calm] ?? 0,
            ),
            Emotion(
              emoji: MoodType.tired.emoji,
              height: _calculateHeight(counts[MoodType.tired] ?? 0).toInt(),
              label: MoodType.tired.label,
              mood: MoodType.tired,
              count: counts[MoodType.tired] ?? 0,
            ),
            Emotion(
              emoji: MoodType.flutter.emoji,
              height: _calculateHeight(counts[MoodType.flutter] ?? 0).toInt(),
              label: MoodType.flutter.label,
              mood: MoodType.flutter,
              count: counts[MoodType.flutter] ?? 0,
            ),
            Emotion(
              emoji: MoodType.stressed.emoji,
              height: _calculateHeight(counts[MoodType.stressed] ?? 0).toInt(),
              label: MoodType.stressed.label,
              mood: MoodType.stressed,
              count: counts[MoodType.stressed] ?? 0,
            ),
          ],
        ),
        error: (err, stack) {
          debugPrint('EmotionGraph Error: $err');
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(height: 8),
                Text(
                  'Error loading moods',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          );
        },
        loading: () =>
            const Center(child: CircularProgressIndicator(color: Colors.white)),
      ),
    );
  }
}

class Emotion extends StatelessWidget {
  const Emotion({
    super.key,
    required this.emoji,
    required this.height,
    required this.label,
    required this.mood,
    required this.count,
  });

  final String emoji;
  final int height;
  final String label;
  final MoodType mood;
  final int count;

  // 31개 1~5,6~10,11~15,16~20,21~25,26~30

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          '$count',
          style: AppTextStyles.labelStatus12w500.copyWith(
            color: AppColors.gray500,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          alignment: AlignmentGeometry.center,
          width: 34,
          height: height.toDouble(),
          decoration: BoxDecoration(
            color: mood.color.withValues(alpha: 0.5),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
            border: Border(
              top: BorderSide(color: mood.color, width: 1),
              left: BorderSide(color: mood.color, width: 1),
              right: BorderSide(color: mood.color, width: 1),
            ),
          ),
          child: Text(emoji, style: const TextStyle(fontSize: 24)),
        ),
        Text(
          label,
          style: AppTextStyles.labelStatus12w500.copyWith(
            color: AppColors.text900,
          ),
        ),
      ],
    );
  }
}
