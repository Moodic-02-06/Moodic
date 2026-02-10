import 'package:flutter/material.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({super.key});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 25, // 동그라미의 크기 (반지름)
                  backgroundColor: Colors.grey[300],
                ),
                Column(children: [Text('현더'), Text('1분전')]),
                Spacer(),
                Icon(Icons.more_vert),
              ],
            ),
            SizedBox(height: 30),
            Row(
              children: [
                CircleAvatar(
                  radius: 50, // 동그라미의 크기 (반지름)
                  backgroundColor: Colors.grey[300],
                ),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('총몽'),
                    Row(
                      children: [
                        Text('현서(HYUNSEO)'),
                        SizedBox(width: 130),
                        Icon(Icons.play_arrow),
                      ],
                    ),

                    SizedBox(height: 30),
                    Row(
                      children: [
                        SizedBox(width: 20),
                        Container(
                          width: 110,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        SizedBox(width: 15),
                        Container(
                          width: 110,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            Center(
              child: Image.asset(
                'assets/images/logo.png',
                width: 340,
                height: 200,
              ),
            ),

            Container(
              width: 60,
              height: 25,
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            Text('오늘 기분'),
            Row(
              children: [
                Icon(Icons.favorite, color: Colors.red, size: 40),
                Text('12'),
                SizedBox(width: 10),
                Icon(Icons.chat_bubble_outline, size: 40),
                Text('12'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
