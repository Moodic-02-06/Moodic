import 'package:flutter_moodic/domain/entity/notification_entity.dart';
import 'package:flutter_moodic/domain/repository/notification_repository.dart';

class CreateNotificationUseCase {
  final NotificationRepository _repository;

  CreateNotificationUseCase(this._repository);

  Future<void> call({
    required String userId, // 알림 받는 사람
    required String type,
    required String message,
    required String senderId,
    required String senderNickname,
    required String senderProfileImage,
    required String targetId,
  }) async {
    // 본인에게 보내는 알림은 제외 (옵션)
    if (userId == senderId) return;

    final notification = NotificationEntity(
      id: '', // Firestore auto-id (DTO에서 처리되거나, 여기서 빈값으로 보내고 Repo/DataSource에서 처리)
      // *DataSource에서 add()를 쓰면 ID 자동 생성됨. Entity의 ID는 생성 시점엔 몰라도 됨.
      userId: userId,
      type: type,
      message: message,
      senderId: senderId,
      senderNickname: senderNickname,
      senderProfileImage: senderProfileImage,
      targetId: targetId,
      createdAt: DateTime.now(),
      isRead: false,
    );

    await _repository.createNotification(notification);
  }
}
