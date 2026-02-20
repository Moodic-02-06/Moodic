class Report {
  final String reportId;
  final String targetId;
  final String targetType; // 'post' or 'comment'
  final String reporterId;
  final String reason;
  final DateTime createdAt;

  Report({
    required this.reportId,
    required this.targetId,
    required this.targetType,
    required this.reporterId,
    required this.reason,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'reportId': reportId,
      'targetId': targetId,
      'targetType': targetType,
      'reporterId': reporterId,
      'reason': reason,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      reportId: json['reportId'] as String,
      targetId: json['targetId'] as String,
      targetType: json['targetType'] as String,
      reporterId: json['reporterId'] as String,
      reason: json['reason'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
