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
                    Text("Maenggo"), Text("반갑습니다"),
                    //
                  ],
                ),
              ],
            ),
            SizedBox(height: 12),
            SizedBox(width: double.infinity, child: Text("이달의 감정 리포트")),
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
                  Container(width: 34, height: 80, color: Colors.blue),
                  Container(width: 34, height: 60, color: Colors.pink),
                ],
              ),
              //
            ),
            SizedBox(height: 12),
            GridView.builder(
              // 그리드뷰 높이를 자식만큼 줄여서 높이값을 지정해줌
              shrinkWrap: true,
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
