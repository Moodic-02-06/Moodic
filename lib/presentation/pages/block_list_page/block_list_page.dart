import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_moodic/core/theme/app_color.dart';
import 'package:flutter_moodic/core/theme/fonts.dart';
import 'block_list_view_model.dart';
import 'package:intl/intl.dart';

class BlockListPage extends ConsumerWidget {
  const BlockListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(blockListViewModelProvider);
    final notifier = ref.read(blockListViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '차단 관리',
          style: AppTextStyles.titlePrimary20w600.copyWith(
            color: AppColors.text900,
          ),
        ),
        centerTitle: true,
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.errorMessage != null
          ? Center(child: Text(state.errorMessage!))
          : state.blocks.isEmpty
          ? Center(
              child: Text(
                '차단된 내역이 없습니다.',
                style: AppTextStyles.bodyPrimary16w500.copyWith(
                  color: AppColors.gray500,
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: state.blocks.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final block = state.blocks[index];
                final targetTypeName = block.targetType == 'post'
                    ? '게시글'
                    : '댓글';
                final dateStr = DateFormat(
                  'yyyy.MM.dd',
                ).format(block.createdAt);

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  title: Text(
                    '차단된 $targetTypeName',
                    style: AppTextStyles.bodyPrimary16w600.copyWith(
                      color: AppColors.text900,
                    ),
                  ),
                  subtitle: Text(
                    '차단일시: $dateStr',
                    style: AppTextStyles.bodySecondary14w500.copyWith(
                      color: AppColors.gray500,
                    ),
                  ),
                  trailing: ElevatedButton(
                    onPressed: () {
                      notifier.unblock(block.targetId);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('차단이 해제되었습니다.')),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary900,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      '차단 해제',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
