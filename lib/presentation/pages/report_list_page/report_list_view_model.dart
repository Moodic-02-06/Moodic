import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_moodic/domain/entity/report.dart';
import 'package:flutter_moodic/presentation/provider/use_case_provider.dart';
import 'package:flutter_moodic/presentation/provider/user_provider.dart';

class ReportListState {
  final List<Report> reports;
  final bool isLoading;
  final String? errorMessage;

  ReportListState({
    this.reports = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  ReportListState copyWith({
    List<Report>? reports,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ReportListState(
      reports: reports ?? this.reports,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class ReportListViewModel extends Notifier<ReportListState> {
  @override
  ReportListState build() {
    Future.microtask(_loadReports);
    return ReportListState();
  }

  Future<void> _loadReports() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final user = ref.read(userProvider).value;
      if (user != null) {
        final reports = await ref
            .read(getMyReportsUseCaseProvider)
            .execute(user.uid);
        state = state.copyWith(reports: reports, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false, errorMessage: '로그인이 필요합니다.');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: '로드 중 오류 발생: $e');
    }
  }
}

final reportListViewModelProvider =
    NotifierProvider<ReportListViewModel, ReportListState>(() {
      return ReportListViewModel();
    });
