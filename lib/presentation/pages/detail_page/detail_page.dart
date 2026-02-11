import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_moodic/core/theme/app_color.dart';
import 'package:flutter_moodic/core/theme/fonts.dart';
import 'package:flutter_moodic/domain/entity/mood_type.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({super.key});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomSheet: Container(
        width: double.infinity,
        child: Padding(
          padding: EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 20),
          child: TextField(
            decoration: InputDecoration(
              hintText: '따뜻한 한마디를 남겨주세요',
              hintStyle: TextStyle(color: AppColors.gray500),
              filled: true,
              fillColor: AppColors.primary600, // 입력 칸 내부 색상
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(52), // 모따기
                borderSide: BorderSide.none,
              ),
              suffixIcon: IconButton(
                icon: Icon(Icons.send, color: AppColors.gray500),
                onPressed: () {},
              ),
            ),
          ),
        ),
      ),
      appBar: AppBar(),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 25, // 동그라미의 크기 (반지름)
                    backgroundColor: Colors.grey[300],
                  ),
                  SizedBox(width: 8),
                  Column(
                    children: [
                      Text(
                        '현더',
                        style: AppTextStyles.bodyPrimary16w600.copyWith(
                          color: AppColors.gray900,
                        ),
                      ),
                      Text('1분전'),
                    ],
                  ),

                  Spacer(),
                  Icon(Icons.more_vert, color: AppColors.gray500),
                ],
              ),
              SizedBox(height: 30),
              Row(
                children: [
                  CircleAvatar(radius: 50, backgroundColor: Colors.grey[300]),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '총몽',
                            style: AppTextStyles.bodyPrimary16w600.copyWith(
                              color: AppColors.gray900,
                            ),
                          ),
                          SizedBox(width: 210),
                          Icon(
                            Icons.play_arrow,
                            size: 28,
                            color: AppColors.gray500,
                          ),
                        ],
                      ),
                      Text('현서(HYUNSEO)'),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          SizedBox(width: 5),
                          Container(
                            padding: EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 16,
                            ),

                            decoration: BoxDecoration(
                              color: AppColors.gray300,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  "Sportyfi",
                                  style: AppTextStyles.titleSecondary18w500
                                      .copyWith(color: AppColors.gray700),
                                ),
                                Transform.rotate(
                                  angle: math.pi / 2,
                                  child: Icon(
                                    Icons.vertical_align_top,
                                    color: AppColors.gray700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 15),
                          Container(
                            padding: EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 16,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.gray300,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  "Youtude",
                                  style: AppTextStyles.titleSecondary18w500
                                      .copyWith(color: AppColors.gray700),
                                ),
                                Transform.rotate(
                                  angle: math.pi / 2,
                                  child: Icon(
                                    Icons.vertical_align_top,
                                    color: AppColors.gray700,
                                  ),
                                ),
                              ],
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
              //투드로 뱃지 연결하기
              Container(
                width: 60,
                height: 25,
                decoration: BoxDecoration(
                  color: AppColors.statusWarning,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(MoodType.happy.label),
              ),
              Text('오늘 기분'),
              Row(
                children: [
                  Icon(Icons.favorite, color: Colors.red, size: 32),
                  Text('12'),
                  SizedBox(width: 10),
                  Icon(Icons.chat_bubble_outline, size: 32),
                  Text('12'),
                ],
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: 30, // 댓글 개수만큼 반복
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(child: Icon(Icons.person)), // 프로필 이미지
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "사용자",
                                style: AppTextStyles.bodySecondary14w500
                                    .copyWith(color: AppColors.gray900),
                              ),
                              Text(
                                'ㅋㅋㅋ',
                                style: AppTextStyles.bodyPrimary16w600.copyWith(
                                  color: AppColors.gray900,
                                ),
                              ), // 리스트에서 해당 순서의 댓글 추출
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
