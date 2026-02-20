import '../repository/report_repository.dart';

class ReportTargetUseCase {
  final ReportRepository _repository;

  ReportTargetUseCase(this._repository);

  Future<void> execute({
    required String targetId,
    required String targetType,
    required String reporterId,
    required String reason,
  }) async {
    return await _repository.reportTarget(
      targetId: targetId,
      targetType: targetType,
      reporterId: reporterId,
      reason: reason,
    );
  }
}
