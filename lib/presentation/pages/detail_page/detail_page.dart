import 'package:flutter/material.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({super.key});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  // 초기 데이터 개수 (원하는 만큼 늘려보세요)
  List<int> items = List.generate(20, (index) => index);
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 25, // 동그라미의 크기 (반지름)
                backgroundColor: Colors.grey[300],
              ),
              Column(children: [Text('현더'), Text('1분전')]),
              Spacer(),
              Icon(Icons.abc),
            ],
          ),
          Row(
            children: [
              CircleAvatar(
                radius: 50, // 동그라미의 크기 (반지름)
                backgroundColor: Colors.grey[300],
              ),
              Column(children: [Text('총몽'), Text('현서(HYUNSEO)')]),
              Spacer(),
              Icon(Icons.abc),
            ],
          ),
          Row(
            children: [
              SizedBox(width: 100),
              Container(width: 120, height: 40, color: Colors.amber),
              SizedBox(width: 10),
              Container(width: 120, height: 40, color: Colors.amber),
            ],
          ),
          SizedBox(height: 200),
          Container(width: 60, height: 25, color: Colors.amber),
          Text('오늘 기분'),
          Row(children: [Icon(Icons.abc), Icon(Icons.abc)]),
        ],
      ),
    );
  }
}
