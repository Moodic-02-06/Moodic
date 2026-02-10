import 'package:flutter/material.dart';

class MyPage extends StatelessWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("프로필"),
        actions: [
          Icon(Icons.edit),
          //
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                // 프로필 이미지 받아와서 넣어주는곳
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
                SizedBox(width: 12),
                // 닉네임,소개
                Column(
                  children: [
                    Text(
                      "Maenggo",
                      style: TextStyle(color: Colors.white, fontSize: 24),
                    ),
                    Text(
                      "반갑습니다",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    //
                  ],
                ),
              ],
            ),
            SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: Text(
                "이달의 감정 리포트",
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            //감정 그래프
            Container(
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
                  Container(width: 34, height: 90, color: Colors.red),
                  Container(width: 34, height: 120, color: Colors.orange),
                  Container(width: 34, height: 80, color: Colors.yellow),
                  Container(width: 34, height: 140, color: Colors.green),
                  Container(
                    alignment: AlignmentGeometry.center,
                    width: 34,
                    height: 80,
                    color: Colors.blue,
                    child: Text('🤔'),
                  ),
                  Container(width: 34, height: 140, color: Colors.green),
                ],
              ),
              //
            ),
            SizedBox(height: 12),
            GridView.builder(
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
            ),
          ],
        ),
      ),
    );
  }
}
