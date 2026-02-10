import 'package:flutter/material.dart';

class MyPageGridView extends StatelessWidget {
  const MyPageGridView({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      // 그리드뷰 높이를 자식만큼 줄여서 높이값을 지정해줌
      shrinkWrap: true,
      // 스크롤이 안되게함 // 전체 스크롤만 가능하게 변경됨
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        crossAxisCount: 2,
      ),
      itemCount: 12,
      itemBuilder: (context, index) {
        return Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey,
          ),
        );
      },
    );
  }
}
