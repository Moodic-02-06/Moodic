import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_moodic/core/theme/app_color.dart';
import 'package:flutter_moodic/core/theme/fonts.dart';
import 'report_list_view_model.dart';
import 'package:intl/intl.dart';

class ReportListPage extends ConsumerWidget {
  const ReportListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reportListViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '신고 내역',
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
          : state.reports.isEmpty
          ? Center(
              child: Text(
                '신고된 내역이 없습니다.',
                style: AppTextStyles.bodyPrimary16w500.copyWith(
                  color: AppColors.gray500,
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: state.reports.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final report = state.reports[index];
                final targetTypeName = report.targetType == 'post'
                    ? '게시글'
                    : '댓글';
                final dateStr = DateFormat(
                  'yyyy.MM.dd HH:mm',
                ).format(report.createdAt);

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  title: Text(
                    '신고 대상: $targetTypeName \n사유: ${report.reason}',
                    style: AppTextStyles.bodyPrimary16w600.copyWith(
                      color: AppColors.text900,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      '신고일시: $dateStr',
                      style: AppTextStyles.bodySecondary14w500.copyWith(
                        color: AppColors.gray500,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
