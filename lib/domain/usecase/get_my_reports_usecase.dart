import '../entity/report.dart';
import '../repository/report_repository.dart';

class GetMyReportsUseCase {
  final ReportRepository _repository;

  GetMyReportsUseCase(this._repository);

  Future<List<Report>> execute(String userId) async {
    return await _repository.getMyReports(userId);
  }
}
