import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_moodic/presentation/pages/my_page/my_page_viewmodel.dart';
import 'package:flutter_moodic/presentation/widgets/mood_badge.dart';
import 'package:flutter_moodic/core/theme/app_color.dart';
import 'package:flutter_moodic/core/theme/fonts.dart';

class EntityGridView extends ConsumerWidget {
  const EntityGridView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myPageState = ref.watch(myPageViewModelProvider);
    final myState = myPageState.value;

    if (myState == null) {
      return const SizedBox.shrink();
    }

    if (myState.feeds.isEmpty) {
      return SizedBox(
        height: 200, // 적절한 높이 설정 (또는 부모에 맞게)
        child: Center(
          child: Text(
            "작성된 피드가 없습니다",
            style: AppTextStyles.bodyPrimary16w500.copyWith(
              color: AppColors.gray500,
            ),
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
        crossAxisCount: 3,
      ),
      itemCount: myState.feeds.length,
      itemBuilder: (context, index) {
        final feed = myState.feeds[index];
        final String? artworkUrl = feed.music.artwork;
        final String? mood = feed.mood;

        return Container(
          decoration: BoxDecoration(
            image: (artworkUrl != null && artworkUrl.isNotEmpty)
                ? DecorationImage(
                    image: NetworkImage(artworkUrl),
                    fit: BoxFit.cover,
                  )
                : null,
            borderRadius: BorderRadius.circular(6),
            color: Colors.grey,
          ),
          child: Stack(
            children: [
              if (artworkUrl == null) const Icon(Icons.abc),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: (mood != null && mood.isNotEmpty)
                      ? MoodBadge(moodLabel: mood.toString())
                      : null,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
