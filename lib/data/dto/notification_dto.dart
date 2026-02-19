import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_moodic/domain/entity/notification_entity.dart';

class NotificationDto extends NotificationEntity {
  NotificationDto({
    required super.id,
    required super.userId,
    required super.type,
    required super.message,
    required super.senderId,
    required super.senderNickname,
    required super.senderProfileImage,
    required super.targetId,
    required super.createdAt,
    required super.isRead,
  });

  factory NotificationDto.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationDto(
      id: doc.id,
      userId: data['userId'] ?? '',
      type: data['type'] ?? '',
      message: data['message'] ?? '',
      senderId: data['senderId'] ?? '',
      senderNickname: data['senderNickname'] ?? '',
      senderProfileImage: data['senderProfileImage'] ?? '',
      targetId: data['targetId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      isRead: data['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'type': type,
      'message': message,
      'senderId': senderId,
      'senderNickname': senderNickname,
      'senderProfileImage': senderProfileImage,
      'targetId': targetId,
      'createdAt': Timestamp.fromDate(createdAt),
      'isRead': isRead,
    };
  }
}
