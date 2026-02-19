import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_moodic/core/theme/app_color.dart';
import 'package:flutter_moodic/core/theme/fonts.dart';
import 'package:flutter_moodic/presentation/pages/temp_profile/temp_profile_view_model.dart';
import 'package:flutter_moodic/presentation/provider/user_provider.dart';
import 'package:flutter_moodic/presentation/widgets/primary_bottom_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TempProfile extends ConsumerStatefulWidget {
  const TempProfile({super.key});

  @override
  ConsumerState<TempProfile> createState() => _TempProfileState();
}

class _TempProfileState extends ConsumerState<TempProfile> {
  late final TextEditingController _nicknameController;

  @override
  void initState() {
    super.initState();
    _nicknameController = TextEditingController();

    Future.microtask(() {
      final initialState = ref.read(tempProfileViewModelProvider);
      _nicknameController.text = initialState.nickname;
    });
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(tempProfileViewModelProvider);
    final viewModel = ref.read(tempProfileViewModelProvider.notifier);
    final userAsync = ref.watch(userProvider);
    final uid = userAsync.value?.uid ?? '';

    ref.listen(tempProfileViewModelProvider, (previous, next) {
      if (next.error != null && previous?.error != next.error) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.error!)));
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text("프로필 설정"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      bottomNavigationBar: PrimaryBottomButton(
        label: '시작하기',
        isLoading: state.isLoading,
        onPressed: state.nickname.length < 2
            ? null
            : () async {
                await viewModel.completeProfile(uid);
              },
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 40),

              // 프로필 이미지 섹션
              Center(
                child: GestureDetector(
                  onTap: viewModel.pickImage,
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.secondary500.withValues(
                                alpha: 0.5,
                              ),
                              blurRadius: 15,
                              offset: const Offset(0, 0),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 60,
                          backgroundColor: AppColors.primary600,
                          backgroundImage: state.profileImage != null
                              ? (state.profileImage!.startsWith('http')
                                    ? NetworkImage(state.profileImage!)
                                          as ImageProvider
                                    : FileImage(File(state.profileImage!)))
                              : null,
                          child: state.profileImage == null
                              ? const Icon(
                                  Icons.person,
                                  size: 64,
                                  color: AppColors.gray400,
                                )
                              : null,
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 4,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.secondary500,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary700.withValues(
                                  alpha: 0.5,
                                ),
                                blurRadius: 15,
                                offset: const Offset(0, 0),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 20,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // 입력 섹션
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "닉네임",
                    style: AppTextStyles.bodyPrimary16w600.copyWith(
                      color: AppColors.text900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary600,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextField(
                      controller: _nicknameController,
                      onChanged: viewModel.onNicknameChanged,
                      textAlign: TextAlign.center,
                      maxLength: 12,
                      style: AppTextStyles.bodyPrimary16w600.copyWith(
                        color: AppColors.text900,
                      ),
                      decoration: InputDecoration(
                        hintText: "사용하실 닉네임을 입력하세요",
                        hintStyle: AppTextStyles.bodySecondary14w500.copyWith(
                          color: AppColors.gray500,
                        ),
                        border: InputBorder.none,
                        counterText: "",
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "• 2~12자의 한글, 영문, 숫자만 사용 가능합니다.",
                    style: AppTextStyles.labelStatus12w500.copyWith(
                      color: AppColors.gray500,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 60),

              Text(
                "반가워요! 🥰\n나중에 언제든지 수정할 수 있으니\n편하게 입력해 주세요.",
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyPrimary16w500.copyWith(
                  color: AppColors.gray400,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
