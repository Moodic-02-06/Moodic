import 'package:uuid/uuid.dart';
import '../../domain/entity/report.dart';
import '../../domain/repository/report_repository.dart';
import '../data_source/remote/report_remote_data_source.dart';

class ReportRepositoryImpl implements ReportRepository {
  final ReportRemoteDataSource _dataSource;
  final Uuid _uuid = const Uuid();

  ReportRepositoryImpl(this._dataSource);

  @override
  Future<void> reportTarget({
    required String targetId,
    required String targetType,
    required String reporterId,
    required String reason,
  }) async {
    final report = Report(
      reportId: _uuid.v4(),
      targetId: targetId,
      targetType: targetType,
      reporterId: reporterId,
      reason: reason,
      createdAt: DateTime.now(),
    );

    await _dataSource.reportTarget(report);
  }

  @override
  Future<List<Report>> getMyReports(String userId) async {
    return await _dataSource.getMyReports(userId);
  }
}
