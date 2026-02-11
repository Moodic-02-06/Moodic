import 'package:flutter/material.dart';

class AppColors {
  // ----------------------------------------------------------------
  // Group 1: Dark Navy / Midnight (어두운 배경 및 네이비 계열)
  // ----------------------------------------------------------------
  static const primary900 = Color(0xFF101022);
  static const primary700 = Color(0xFF1A1B2E);
  static const primary600 = Color(0xFF242544);

  // ----------------------------------------------------------------
  // Group 2: Lime / Acid Green (밝은 라임 강조색)
  // ----------------------------------------------------------------
  static const secondary600 = Color(0xFFB6DE2F);
  static const secondary500 = Color(0xFFD0FA3A);
  static const secondary400 = Color(0xFFE4FF6A);

  // ----------------------------------------------------------------
  // Group 3: Cool Greys (쿨 그레이 및 보조 색상)
  // ----------------------------------------------------------------
  static const text900 = Color(0xFFF8FAFF);
  static const text600 = Color(0xFF8B99AE);

  // ----------------------------------------------------------------
  // Group 4: Status Colors (상태 표시용: 에러, 성공, 경고)
  // ----------------------------------------------------------------
  static const stateError = Color(0xFFFF4D4F); // Red
  static const statusSuccess = Color(0xFF22E58B); // Green
  static const statusWarning = Color(0xFFFACC15); // Yellow/Gold

  // ----------------------------------------------------------------
  // Group 5: Slate Scale (슬레이트 그레이 스케일)
  // ----------------------------------------------------------------
  static const gray900 = Color(0xFFF1F5F9);
  static const gray700 = Color(0xFFCBD5E1);
  static const gray500 = Color(0xFF94A3B8);
  static const gray400 = Color(0xFF6E7A90);
  static const gray300 = Color(0xFF475569);
  static const gray100 = Color(0xFF1E293B);

  static Color? get primary500 => null;
}
