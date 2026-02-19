import 'dart:async';

import 'package:flutter_moodic/core/service/notification_service.dart';
import 'package:flutter_moodic/domain/entity/notification_entity.dart';
import 'package:flutter_moodic/presentation/provider/use_case_provider.dart';
import 'package:flutter_moodic/presentation/provider/user_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final notificationProvider = StreamProvider<List<NotificationEntity>>((ref) {
  final user = ref.watch(userProvider).value;

  if (user == null || !user.isNotificationEnabled) {
    return const Stream.empty();
  }

  return ref.watch(listenNotificationsUseCaseProvider).call(user.uid);
});

// 전역적으로 알림을 듣고 처리하는 Provider
final notificationListenerProvider = Provider<void>((ref) {
  ref.listen(notificationProvider, (previous, next) {
    next.whenData((notifications) {
      // 가장 최근 알림 확인
      if (notifications.isEmpty) return;

      final latest = notifications.first;

      // 이미 읽었거나, 너무 오래된 알림(앱 켜기 전)은 무시하는 로직이 필요할 수 있음
      // 여기서는 간단히 5초 이내의 알림만 로컬 푸시로 띄움 (데모용)
      // 실제로는 'lastReadId' 등을 관리하거나, 서버에서 'pushSent' 플래그를 관리해야 함.
      // 하지만 요구사항상 "로컬 알림 오게 해달라"는 것에 집중.

      final now = DateTime.now();
      if (latest.createdAt.isAfter(now.subtract(const Duration(seconds: 5))) &&
          !latest.isRead) {
        NotificationService().showNotification(
          id: latest.hashCode,
          title: 'Moodic', // 앱 이름 또는 알림 타입
          body: latest.message,
          payload: latest.targetId,
        );
      }
    });
  });
});
