import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_moodic/data/dto/notification_dto.dart';

class NotificationRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createNotification(NotificationDto notification) async {
    // 알림 받는 사람의 서브컬렉션에 추가
    await _firestore
        .collection('user')
        .doc(notification.userId)
        .collection('notifications')
        .add(notification.toJson());
  }

  Stream<List<NotificationDto>> getNotificationStream(String userId) {
    return _firestore
        .collection('user')
        .doc(userId)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return NotificationDto.fromFirestore(doc);
          }).toList();
        });
  }

  Future<void> markAsRead(String userId, String notificationId) async {
    await _firestore
        .collection('user')
        .doc(userId)
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }
}
