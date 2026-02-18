import 'package:flutter/material.dart';
import 'package:flutter_moodic/core/theme/app_color.dart';
import 'package:flutter_moodic/core/theme/fonts.dart';

class SearchAppBar extends StatelessWidget implements PreferredSizeWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSearch;

  const SearchAppBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onSearch,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,

      title: TextField(
        controller: controller,
        focusNode: focusNode,
        textInputAction: TextInputAction.search,

        decoration: InputDecoration(
          hintText: '음악으로 검색해보세요',
          hintStyle: AppTextStyles.bodyPrimary16w500.copyWith(
            color: AppColors.gray400,
          ),

          prefixIcon: const Icon(Icons.search, color: AppColors.gray400),

          filled: true,

          contentPadding: const EdgeInsets.symmetric(
            vertical: 0,
            horizontal: 12,
          ),

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
        ),

        onSubmitted: (_) => onSearch(),
      ),
    );
  }
}
