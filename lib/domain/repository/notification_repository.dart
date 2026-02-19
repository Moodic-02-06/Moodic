import 'package:flutter_moodic/domain/entity/notification_entity.dart';

abstract class NotificationRepository {
  Future<void> createNotification(NotificationEntity notification);
  Stream<List<NotificationEntity>> getNotificationStream(String userId);
  Future<void> markAsRead(String notificationId);
}
