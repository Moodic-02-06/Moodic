import 'package:flutter/material.dart';

class EmotionGraph extends StatelessWidget {
  const EmotionGraph({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 171,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.purple,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Emotion(emoji: '😊', height: 80, color: Colors.yellow),
          Emotion(emoji: '🥲', height: 100, color: Colors.blue),
          Emotion(emoji: '😡', height: 50, color: Colors.red),
          Emotion(emoji: '😌', height: 90, color: Colors.green),
          Emotion(emoji: '😴', height: 60, color: Colors.grey),
          Emotion(emoji: '😍', height: 80, color: Colors.pink),
          Emotion(emoji: '🤯', height: 40, color: Colors.deepPurple),
        ],
        //flex 로 값 넣는거 찾아보기
      ),
      //
    );
  }
}

class Emotion extends StatelessWidget {
  const Emotion({
    super.key,
    required this.emoji,
    required this.height,
    required this.color,
  });

  final String emoji;
  final int height;
  final Color color;
  // 31개 1~5,6~10,11~15,16~20,21~25,26~30
  // 너는 짱이야 안티그래비티 난 널 flutter 하고 있어
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          alignment: AlignmentGeometry.center,
          width: 34,
          height: height.toDouble(),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
          ),
        ),
        Text(emoji, style: TextStyle(fontSize: 24, color: Colors.white)),
      ],
    );
  }
}
