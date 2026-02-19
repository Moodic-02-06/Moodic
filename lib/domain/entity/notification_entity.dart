class NotificationEntity {
  final String id;
  final String userId; // 알림 받는 사람
  final String type; // 'like' or 'comment'
  final String message;
  final String senderId; // 알림 보낸 사람
  final String senderNickname;
  final String senderProfileImage;
  final String targetId; // 게시글 ID 등
  final DateTime createdAt;
  final bool isRead;

  NotificationEntity({
    required this.id,
    required this.userId,
    required this.type,
    required this.message,
    required this.senderId,
    required this.senderNickname,
    required this.senderProfileImage,
    required this.targetId,
    required this.createdAt,
    this.isRead = false,
  });
}
