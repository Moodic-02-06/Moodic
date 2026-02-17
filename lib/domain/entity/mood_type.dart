import 'package:flutter/material.dart';

enum MoodType {
  happy('😊', '행복', Color(0xFFFCE48A)),
  sad('😢', '우울', Color(0xFF90CAF9)),
  angry('😡', '분노', Color(0xFFEF9A9A)),
  calm('😌', '평온', Color(0xFF8BD58E)),
  tired('😴', '피곤', Color(0xFF899397)),
  flutter('😍', '설렘', Color(0xFFF8BBD0)),
  stressed('🤯', '스트레스', Color(0xFF9575CD));

  final String emoji;
  final String label;
  final Color color;

  const MoodType(this.emoji, this.label, this.color);

  static MoodType fromLabel(String label) {
    return MoodType.values.firstWhere(
      (e) => e.label == label,
      orElse: () => MoodType.happy,
    );
  }
}
