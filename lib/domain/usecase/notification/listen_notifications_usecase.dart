import 'package:flutter_moodic/domain/entity/notification_entity.dart';
import 'package:flutter_moodic/domain/repository/notification_repository.dart';

class ListenNotificationsUseCase {
  final NotificationRepository _repository;

  ListenNotificationsUseCase(this._repository);

  Stream<List<NotificationEntity>> call(String userId) {
    return _repository.getNotificationStream(userId);
  }
}
