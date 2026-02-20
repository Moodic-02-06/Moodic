class Block {
  final String targetId;
  final String targetType; // 'post' or 'comment'
  final DateTime createdAt;

  Block({
    required this.targetId,
    required this.targetType,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'targetId': targetId,
      'targetType': targetType,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Block.fromJson(Map<String, dynamic> json) {
    return Block(
      targetId: json['targetId'] as String,
      targetType: json['targetType'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
