import 'package:flutter/material.dart';
import 'package:flutter_moodic/core/theme/app_color.dart';
import 'package:flutter_moodic/core/theme/fonts.dart';

class CommentInputField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSubmit;

  const CommentInputField({
    super.key,
    required this.controller,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 10,
      ),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.gray100)),
        color: AppColors.primary900,
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: '따뜻한 한마디를 남겨주세요',
          hintStyle: AppTextStyles.bodySecondary14w500.copyWith(
            color: AppColors.gray500,
          ),
          filled: true,
          fillColor: AppColors.primary600,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          suffixIcon: IconButton(
            icon: const Icon(Icons.send, color: AppColors.gray400),
            onPressed: onSubmit,
          ),
        ),
      ),
    );
  }
}
