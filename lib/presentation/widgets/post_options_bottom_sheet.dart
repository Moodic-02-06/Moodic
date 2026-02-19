import 'package:flutter/material.dart';
import 'package:flutter_moodic/core/theme/app_color.dart';

class PostOptionsBottomSheet extends StatelessWidget {
  final bool isMyPost; // 내가 쓴 글인지 확인
  final VoidCallback? onEdit; // 수정 누를 때 실행할 함수
  final VoidCallback? onDelete; // 삭제 누를 때 실행할 함수
  final VoidCallback? onReport; // 신고 누를 때 실행할 함수

  const PostOptionsBottomSheet({
    super.key,
    required this.isMyPost,
    this.onEdit,
    this.onDelete,
    this.onReport,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // 바텀시트 전체 배경색과 둥근 모서리 설정
      decoration: const BoxDecoration(
        color: AppColors.primary700,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // 내용물 높이만큼만 자리를 차지하게 함
        children: [
          const SizedBox(height: 12),

          // 1. 맨 위 핸들바 (회색 짧은 선)
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.gray300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          const SizedBox(height: 12),

          // 2. 조건에 따라 메뉴 보여주기
          ListTile(
            leading: const Icon(Icons.link, color: AppColors.gray500),
            title: const Text(
              '게시글 링크 복사',
              style: TextStyle(color: Colors.white),
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          if (isMyPost) ...[
            // 내가 쓴 글일 때 보여줄 메뉴
            ListTile(
              leading: const Icon(
                Icons.edit_outlined,
                color: AppColors.gray500,
              ),
              title: const Text('수정하기', style: TextStyle(color: Colors.white)),
              onTap: onEdit,
            ),
            ListTile(
              leading: const Icon(
                Icons.delete_outline,
                color: AppColors.stateError,
              ),
              title: const Text(
                '삭제하기',
                style: TextStyle(color: AppColors.stateError),
              ),
              onTap: onDelete,
            ),
          ] else ...[
            // 남이 쓴 글일 때 보여줄 메뉴
            ListTile(
              leading: const Icon(
                Icons.report_gmailerrorred_outlined,
                color: AppColors.stateError,
              ),
              title: const Text(
                '신고하기',
                style: TextStyle(color: AppColors.stateError),
              ),
              onTap: onReport,
            ),
          ],

          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
