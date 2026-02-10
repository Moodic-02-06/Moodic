import 'package:flutter/material.dart';
import 'package:flutter_moodic/core/theme/app_color.dart';
import 'package:flutter_moodic/core/theme/fonts.dart';
import 'package:flutter_moodic/domain/entity/mood_type.dart';

class EmotionGraph extends StatelessWidget {
  const EmotionGraph({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 171,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColors.primary600,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Emotion(
            emoji: MoodType.happy.emoji,
            height: 80,
            label: MoodType.happy.label,
            mood: MoodType.happy,
          ),
          Emotion(
            emoji: MoodType.sad.emoji,
            height: 100,
            label: MoodType.sad.label,
            mood: MoodType.sad,
            //
          ),
          Emotion(
            emoji: MoodType.angry.emoji,
            height: 50,
            label: MoodType.angry.label,
            mood: MoodType.angry,
            //
          ),
          Emotion(
            emoji: MoodType.calm.emoji,
            height: 90,
            label: MoodType.calm.label,
            mood: MoodType.calm,
            //
          ),
          Emotion(
            emoji: MoodType.tired.emoji,
            height: 60,
            label: MoodType.tired.label,
            mood: MoodType.tired,
            //
          ),
          Emotion(
            emoji: MoodType.flutter.emoji,
            height: 80,
            label: MoodType.flutter.label,
            mood: MoodType.flutter,
            //
          ),
          Emotion(
            emoji: MoodType.stressed.emoji,
            height: 40,
            label: MoodType.stressed.label,
            mood: MoodType.stressed,
            //
          ),
        ],
        //flex 로 값 넣는거 찾아보기
      ),
      //
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
  });

  final String emoji;
  final int height;
  final String label;
  final MoodType mood;

  // 31개 1~5,6~10,11~15,16~20,21~25,26~30

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
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
