import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_moodic/core/theme/app_color.dart';
import 'package:flutter_moodic/core/theme/fonts.dart';
import 'package:image_picker/image_picker.dart';

import 'package:flutter_moodic/data/repository/user_repository_impl.dart';
import 'package:flutter_moodic/domain/entity/user_entity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_moodic/presentation/provider/user_provider.dart';

import 'package:flutter_moodic/core/router/app_routers.dart';
import 'package:go_router/go_router.dart';

class MyPageEdit extends ConsumerStatefulWidget {
  const MyPageEdit({super.key});

  @override
  ConsumerState<MyPageEdit> createState() => _MyPageEditState();
}

class _MyPageEditState extends ConsumerState<MyPageEdit> {
  bool _isSwitched = false;
  XFile? _xFile;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nicknameController;
  late TextEditingController _bioController;

  @override
  void initState() {
    super.initState();
    final user = ref.read(userProvider).value;
    _nicknameController = TextEditingController(text: user?.nickname ?? "");
    _bioController = TextEditingController(text: user?.bio ?? "");
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _onSave() {
    final user = ref.read(userProvider).value;
    // 이미지 유효성 검사 (새로 선택한 이미지도 없고, 기존 이미지도 없는 경우)
    if (_xFile == null &&
        (user?.profileImage == null || user!.profileImage!.isEmpty)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("첨부된 이미지가 없습니다")));
      return;
    }

    // 폼 유효성 검사 (닉네임, 소개)
    if (_formKey.currentState!.validate()) {
      _saveProfile(user);
    }
  }

  Future<void> _saveProfile(UserEntity? user) async {
    if (user == null) return;

    try {
      String? imageUrl = user.profileImage;

      // 1. 이미지가 변경되었다면 업로드
      if (_xFile != null) {
        imageUrl = await ref
            .read(userRepositoryProvider)
            .uploadProfileImage(_xFile!.path, user.uid);
      }

      // 2. 유저 정보 업데이트
      final updatedUser = user.copyWith(
        nickname: _nicknameController.text,
        bio: _bioController.text,
        profileImage: imageUrl,
      );

      await ref.read(userRepositoryProvider).updateUser(updatedUser);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("프로필이 저장되었습니다")));
        Navigator.pop(context);
        // ref.refresh(userProvider); // StreamProvider라 자동 갱신됨
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("저장 실패: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider).value;

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
            onPressed: _onSave,
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
                        color:
                            (_xFile == null &&
                                (user?.profileImage == null ||
                                    user!.profileImage!.isEmpty))
                            ? Colors.grey
                            : Colors.transparent,
                        child: _xFile != null
                            ? Image.file(File(_xFile!.path), fit: BoxFit.cover)
                            : (user?.profileImage != null &&
                                  user!.profileImage!.isNotEmpty)
                            ? Image.network(
                                user.profileImage!,
                                fit: BoxFit.cover,
                              ) // 기존 이미지 (URL 가정)
                            : null,
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
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.primary600,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextFormField(
                        maxLength: 12,
                        // 한글,영문,숫자만 입력되게
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[a-zA-Z0-9가-힣]'),
                          ),
                        ],
                        controller: _nicknameController,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "닉네임이 작성되지 않았습니다";
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: "12자 이내로 한글,영문,숫자만 사용가능합니다",
                          hintStyle: AppTextStyles.bodySecondary14w500.copyWith(
                            color: AppColors.text600,
                          ),
                          border: InputBorder.none,
                          // 에러 스타일 커스텀이 필요하면 추가
                          errorStyle: TextStyle(color: AppColors.stateError),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 8,
                            horizontal: 12,
                          ), // 패딩 조정
                          counterText: "",
                        ),
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyPrimary16w600.copyWith(
                          color: AppColors.text900,
                        ),
                      ),
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
                      padding: EdgeInsets.all(12),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.primary600,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextFormField(
                        maxLength: 80,
                        maxLines: 2,
                        controller: _bioController,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "소개 내용이 작성되지 않았습니다";
                          }
                          return null;
                        },
                        textInputAction: TextInputAction.newline,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          errorStyle: TextStyle(color: AppColors.stateError),
                        ),
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyPrimary16w600.copyWith(
                          color: AppColors.text900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "알림",
                      style: AppTextStyles.bodyPrimary16w600.copyWith(
                        color: AppColors.text900,
                      ),
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
                                onPressed: () async {
                                  Navigator.pop(context); // 다이얼로그 닫기
                                  // 스플래시로 이동하여 로그아웃 처리
                                  if (context.mounted) {
                                    context.goNamed(
                                      AppRoutes.SplashPage.name,
                                      queryParameters: {'action': 'logout'},
                                    );
                                  }
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
                            content: Text(
                              "회원탈퇴 하시겠습니까?\n탈퇴 시 작성하신 게시글이 모두 삭제됩니다.",
                            ),
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
                                onPressed: () async {
                                  Navigator.pop(context); // 다이얼로그 닫기
                                  // 스플래시로 이동하여 탈퇴 처리
                                  if (context.mounted) {
                                    context.goNamed(
                                      AppRoutes.SplashPage.name,
                                      queryParameters: {'action': 'delete'},
                                    );
                                  }
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
