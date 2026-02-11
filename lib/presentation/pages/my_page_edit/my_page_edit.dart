import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_moodic/core/theme/app_color.dart';
import 'package:flutter_moodic/core/theme/fonts.dart';
import 'package:image_picker/image_picker.dart';

class MyPageEdit extends StatefulWidget {
  const MyPageEdit({super.key});

  @override
  State<MyPageEdit> createState() => _MyPageEditState();
}

class _MyPageEditState extends State<MyPageEdit> {
  bool _isSwitched = false;
  XFile? _xFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "프로필 편집",
          style: AppTextStyles.titlePrimary20w600.copyWith(
            color: AppColors.text900,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(Icons.save, color: AppColors.gray500),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 90,
                height: 90,
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: Container(
                        width: 90,
                        height: 90,
                        color: _xFile == null
                            ? Colors.grey
                            : Colors.transparent,
                        child: _xFile == null
                            ? null
                            : Image.file(File(_xFile!.path), fit: BoxFit.cover),
                      ),
                    ),
                    Align(
                      alignment: AlignmentGeometry.bottomRight,
                      child: GestureDetector(
                        // 5-12
                        onTap: () async {
                          XFile? xFile = await ImagePicker().pickImage(
                            source: ImageSource.gallery,
                          );
                          setState(() {
                            _xFile = xFile;
                          });
                        },
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: AppColors.secondary600,
                          ),
                          child: Center(
                            child: Icon(Icons.camera_alt, color: Colors.black),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12),
              Text(
                "닉네임",
                style: AppTextStyles.bodyPrimary16w600.copyWith(
                  color: AppColors.text900,
                ),
              ),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(12),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.primary600,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '홍길동',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyPrimary16w600.copyWith(
                    color: AppColors.text900,
                  ),
                ),
              ),
              SizedBox(height: 12),
              Text(
                "2~12자의 한글, 영문, 숫자만 사용가능 합니다",
                style: TextStyle(fontSize: 10, color: Colors.white),
              ),
              SizedBox(height: 12),
              Container(
                width: double.infinity,
                height: 1,
                color: AppColors.primary600,
              ),
              SizedBox(height: 12),
              Text(
                "소개",
                style: AppTextStyles.bodyPrimary16w600.copyWith(
                  color: AppColors.text900,
                ),
              ),
              SizedBox(height: 12),
              Container(
                padding: EdgeInsets.all(24),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.primary600,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _isSwitched
                          ? AppColors.secondary500
                          : AppColors.primary600,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "알림",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  Spacer(),
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
              Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text("로그아웃"),
                            content: Text("로그아웃 하시겠습니까?"),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  "취소",
                                  style: TextStyle(color: AppColors.text600),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  "로그아웃",
                                  style: TextStyle(color: AppColors.stateError),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Text(
                      "로그아웃",
                      style: TextStyle(color: AppColors.statusSuccess),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text("회원탈퇴"),
                            content: Text("회원탈퇴 하시겠습니까?"),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  "취소",
                                  style: TextStyle(color: AppColors.text600),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  "회원탈퇴",
                                  style: TextStyle(color: AppColors.stateError),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Text(
                      "회원탈퇴",
                      style: TextStyle(color: AppColors.stateError),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
