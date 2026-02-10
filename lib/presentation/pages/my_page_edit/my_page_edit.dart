import 'package:flutter/material.dart';

class MyPageEdit extends StatefulWidget {
  const MyPageEdit({super.key});

  @override
  State<MyPageEdit> createState() => _MyPageEditState();
}

class _MyPageEditState extends State<MyPageEdit> {
  bool _isSwitched = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("프로필 편집")),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            children: [
              SizedBox(
                width: 100,
                height: 100,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Container(
                        width: 100,
                        height: 100,
                        color: Colors.grey,
                      ),
                    ),
                    Align(
                      alignment: AlignmentGeometry.bottomRight,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          color: Colors.green,
                        ),
                        child: Center(
                          child: Icon(Icons.camera_alt, color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 12),
              Text("닉네임", style: TextStyle(color: Colors.white)),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '홍길동',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black),
                ),
              ),
              SizedBox(height: 12),
              Text(
                "2~12자의 한글, 영문, 숫자만 사용가능 합니다",
                style: TextStyle(fontSize: 10, color: Colors.white),
              ),
              SizedBox(height: 12),
              Container(width: double.infinity, height: 1, color: Colors.grey),
              SizedBox(height: 12),
              Text("소개", style: TextStyle(color: Colors.white)),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(24),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "알림",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  Spacer(),
                  //토글버튼
                  Switch(
                    value: _isSwitched,
                    onChanged: (value) {
                      setState(() {
                        _isSwitched = value;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
