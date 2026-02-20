import '../entity/report.dart';

abstract class ReportRepository {
  Future<void> reportTarget({
    required String targetId,
    required String targetType,
    required String reporterId,
    required String reason,
  });
  Future<List<Report>> getMyReports(String userId);
}
