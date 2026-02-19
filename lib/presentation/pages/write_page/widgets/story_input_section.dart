import 'package:flutter/material.dart';
import 'package:flutter_moodic/core/theme/app_color.dart';
import 'package:flutter_moodic/core/theme/fonts.dart';
import 'package:flutter_moodic/presentation/pages/write_page/write_page_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//////////////////////////////////////////////////
/// 텍스트 입력
//////////////////////////////////////////////////

class StoryInputSection extends ConsumerStatefulWidget {
  const StoryInputSection({super.key});

  @override
  ConsumerState<StoryInputSection> createState() => _StoryInputSectionState();
}

class _StoryInputSectionState extends ConsumerState<StoryInputSection> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.text = ref.read(writeViewModelProvider).content;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<String>(
      writeViewModelProvider.select((state) => state.content),
      (previous, next) {
        if (_controller.text != next) {
          _controller.text = next;
          _controller.selection = TextSelection.fromPosition(
            TextPosition(offset: _controller.text.length),
          );
        }
      },
    );

    final content = ref.watch(writeViewModelProvider.select((s) => s.content));
    const int maxLength = 280;

    return Container(
      height: 260,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary700,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary600),
      ),
      child: Stack(
        children: [
          Positioned(
            bottom: 0,
            right: 0,
            child: Text(
              '${content.length}/$maxLength',
              style: AppTextStyles.labelStatus12w500.copyWith(
                color: AppColors.gray300,
              ),
            ),
          ),
          TextField(
            onChanged: (value) {
              if (value.length <= maxLength) {
                ref.read(writeViewModelProvider.notifier).setContent(value);
              }
            },
            maxLines: null,
            expands: true,
            maxLength: maxLength, // 시스템적으로 제한
            style: AppTextStyles.bodyPrimary16w500.copyWith(
              color: AppColors.text900,
            ),
            controller: _controller,
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: '오늘의 이야기를 적어주세요..',
              hintStyle: TextStyle(color: AppColors.gray400),
            ),
          ),
        ],
      ),
    );
  }
}
