import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../domain/entity/report.dart';

class ReportRemoteDataSource {
  final FirebaseFirestore _firestore;

  ReportRemoteDataSource(this._firestore);

  Future<void> reportTarget(Report report) async {
    await _firestore
        .collection('reports')
        .doc(report.reportId)
        .set(report.toJson());
  }

  Future<List<Report>> getMyReports(String userId) async {
    final snapshot = await _firestore
        .collection('reports')
        .where('reporterId', isEqualTo: userId)
        .get();

    final reports = snapshot.docs
        .map((doc) => Report.fromJson(doc.data()))
        .toList();
    reports.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return reports;
  }
}
