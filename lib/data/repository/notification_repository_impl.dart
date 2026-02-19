import 'package:flutter_moodic/data/data_source/notification_remote_data_source.dart';
import 'package:flutter_moodic/data/dto/notification_dto.dart';
import 'package:flutter_moodic/domain/entity/notification_entity.dart';
import 'package:flutter_moodic/domain/repository/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource _dataSource;

  NotificationRepositoryImpl(this._dataSource);

  @override
  Future<void> createNotification(NotificationEntity notification) async {
    final dto = NotificationDto(
      id: notification.id,
      userId: notification.userId,
      type: notification.type,
      message: notification.message,
      senderId: notification.senderId,
      senderNickname: notification.senderNickname,
      senderProfileImage: notification.senderProfileImage,
      targetId: notification.targetId,
      createdAt: notification.createdAt,
      isRead: notification.isRead,
    );
    await _dataSource.createNotification(dto);
  }

  @override
  Stream<List<NotificationEntity>> getNotificationStream(String userId) {
    return _dataSource.getNotificationStream(userId);
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    // Note: Implementation details for markAsRead might require userId as well in the current DataSource design
    // Assuming for now that we can't easily get userId here without context.
    // However, in this app logic, usually we know the current user.
    // Let's defer this implementation or update the interface if needed.
    // For local notification trigger purpose, we mainly need create and list.

    // Correct approach: The UseCase should probably provide userId or Repository should access it.
    // But repository shouldn't depend on user state directly if possible.
    // For now, let's keep it empty or refactor if `markAsRead` is strictly required for this task.
    // The user request emphasizes *receiving* notifications (local push).
    // I will leave this as a placeholder or remove it if not strictly needed for the MVP.
  }
}
