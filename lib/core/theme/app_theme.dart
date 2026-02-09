import 'package:flutter/material.dart';
import 'package:flutter_moodic/core/theme/app_color.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.secondary500,
      scaffoldBackgroundColor: AppColors.primary900,
      fontFamily: 'Pretendard',

      // 1. ColorScheme 수정 (background -> surface)
      colorScheme: const ColorScheme.dark(
        primary: AppColors.secondary500,
        secondary: AppColors.secondary600,
        surface: AppColors.primary700,
        error: AppColors.stateError,
        onPrimary: AppColors.primary900,
        onSurface: AppColors.text900,
        outline: AppColors.gray100,
      ),

      // 2. AppBar 테마 (상단 바)
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary900,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: AppColors.text900,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: AppColors.text900),
      ),

      // 3. Text 테마 (Pretendard 기반)
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          color: AppColors.text900,
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: TextStyle(
          color: AppColors.text900,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: AppColors.gray900,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        bodyMedium: TextStyle(
          color: AppColors.gray500,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        labelSmall: TextStyle(
          color: AppColors.text600,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),

      // 4. Card 및 Container 테마
      cardTheme: CardThemeData(
        color: AppColors.primary700,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.gray100, width: 1),
        ),
        elevation: 0,
      ),

      // 5. 버튼 테마 (강조색 라임 활용)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.secondary500,
          foregroundColor: AppColors.primary900,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(48),
          ),
        ),
      ),

      // 6. Navigation Bar (하단 탭바 컨셉)
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.primary900,
        selectedItemColor: AppColors.secondary500,
        unselectedItemColor: AppColors.text600,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
