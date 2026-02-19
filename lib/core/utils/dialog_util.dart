import 'package:flutter/material.dart';
import 'package:flutter_moodic/core/theme/app_color.dart';

class DialogUtil {
  /// 예 / 아니오 선택 다이얼로그
  static Future<bool> showConfirmBoolDialog(
    BuildContext context, {
    Widget? title,
    Widget? content,

    String cancelText = '취소',
    String confirmText = '확인',

    Color? confirmColor,
    bool barrierDismissible = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) {
        return AlertDialog(
          title: title,
          content: content,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(cancelText),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: confirmColor),
              child: Text(confirmText),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }

  /// 삭제 전용 프리셋 (옵션)
  static Future<void> showDeleteDialog(
    BuildContext context, {
    required VoidCallback onConfirm,
    String title = '게시글 삭제',
    String content = '정말로 삭제하시겠어요?\n삭제 후 복구할 수 없습니다.',
  }) async {
    final result = await showConfirmBoolDialog(
      context,
      title: Text(title),
      content: Text(content),
      confirmText: '삭제',
      confirmColor: AppColors.stateError,
    );

    if (result) {
      onConfirm();
    }
  }
}
