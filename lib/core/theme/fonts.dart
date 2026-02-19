import 'package:flutter/material.dart';

class AppTextStyles {
  static const String fontFamily = 'Pretendard';

  // --- Title (제목) ---

  /// Title-Primary: AppBar 타이틀, 메인 제목 (20px / SemiBold)
  static const TextStyle titlePrimary20w600 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  /// Title-Secondary-bold: 카드 제목, 기기명, 가격 (18px / SemiBold)
  static const TextStyle titleSecondary18w600 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  /// Title-Secondary: 카드 제목, 기기명, 가격 (18px / Medium)
  static const TextStyle titleSecondary18w500 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w500,
  );

  // --- Body (본문) ---

  /// Body-primary: 기본 본문, 주요 설명 (16px / SemiBold)
  static const TextStyle bodyPrimary16w600 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  /// Body-primary: 기본 본문, 주요 설명 (16px / Medium)
  static const TextStyle bodyPrimary16w500 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  /// Body-secondary: 보조 설명 (14px / Medium)
  static const TextStyle bodySecondary14w500 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  // --- Label ---

  /// label-status: 배지, 상태 라벨 (12px / Medium)
  static const TextStyle labelStatus12w500 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  /// label-status: 채팅 시간 (10px / Medium)
  static const TextStyle labelChat10w500 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w500,
  );
}
