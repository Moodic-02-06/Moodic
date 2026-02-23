import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService();
});

class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  FirebaseAnalytics get analytics => _analytics;

  Future<void> logEvent({
    required String name,
    Map<String, Object>? parameters,
  }) async {
    await _analytics.logEvent(name: name, parameters: parameters);
  }

  Future<void> setUserId(String? id) async {
    await _analytics.setUserId(id: id);
  }

  Future<void> setCurrentScreen({
    required String screenName,
    String screenClassOverride = 'Flutter',
  }) async {
    await _analytics.logScreenView(
      screenName: screenName,
      screenClass: screenClassOverride,
    );
  }

  // 자주 쓰이는 이벤트들을 메서드로 미리 정의해 두면 오타 방지 및 관리에 좋습니다.
  Future<void> logLogin({required String loginMethod}) async {
    await _analytics.logLogin(loginMethod: loginMethod);
  }

  Future<void> logPostCreated({required String postId}) async {
    await logEvent(name: 'post_created', parameters: {'post_id': postId});
  }

  Future<void> logSearch({required String searchTerm}) async {
    await _analytics.logSearch(searchTerm: searchTerm);
  }

  Future<void> logPlayPreview({required String musicTitle}) async {
    await logEvent(
      name: 'play_preview',
      parameters: {'music_title': musicTitle},
    );
  }

  Future<void> logPlayDetail({
    required String musicTitle,
    required String postId,
  }) async {
    await logEvent(
      name: 'play_detail',
      parameters: {'music_title': musicTitle, 'post_id': postId},
    );
  }

  Future<void> logExternalLinkClick({
    required String platform,
    required String musicTitle,
    required String postId,
  }) async {
    await logEvent(
      name: platform,
      parameters: {'music_title': musicTitle, 'post_id': postId},
    );
  }

  Future<void> logTabChanged({required String tabName}) async {
    // 탭 이름 자체를 이벤트명으로 발생시켜 밖에서도 바로 보이게 처리
    await logEvent(name: tabName);
  }
}
