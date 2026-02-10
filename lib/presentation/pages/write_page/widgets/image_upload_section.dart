import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_moodic/core/theme/app_color.dart';
import 'package:flutter_moodic/core/theme/fonts.dart';
import 'package:flutter_moodic/presentation/pages/write_page/write_page_view_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ImageUploadSection extends ConsumerWidget {
  const ImageUploadSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageUrls = ref.watch(writeViewModelProvider).imageUrls;
    final viewModel = ref.read(writeViewModelProvider.notifier);

    // 이미지 피커
    final picker = ImagePicker();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 선택된 이미지들과 추가 버튼을 보여주는 가로 스크롤 영역
        SizedBox(
          height: 80,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            // 추가 버튼(index 0)을 포함하기 위해 실제 이미지 개수 + 1
            itemCount: imageUrls.length + 1,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              // 첫 번째 아이템은 항상 '이미지 추가' 버튼
              if (index == 0) {
                return GestureDetector(
                  onTap: () async {
                    try {
                      // 갤러리에서 여러 장의 이미지를 선택
                      final List<XFile> images = await picker.pickMultiImage();

                      if (images.isNotEmpty) {
                        // 선택된 XFile 리스트를 경로(String) 리스트로 변환하여 ViewModel에 전달
                        final List<String> paths = images
                            .map((e) => e.path)
                            .toList();
                        viewModel.addImages(paths);
                      }
                    } on PlatformException catch (e) {
                      // 이미 피커가 실행 중일 때 발생하는 에러 방지
                      if (e.code == 'already_active') {
                        debugPrint("이미 이미지 피커가 열려있습니다.");
                      } else {
                        rethrow;
                      }
                    } catch (e) {
                      debugPrint("이미지 선택 중 오류: $e");
                    }
                  },
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppColors.primary700,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.primary600),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate,
                          color: AppColors.gray400,
                        ),
                        // 현재 선택된 이미지 개수 표시
                        Text(
                          '${imageUrls.length}/10',
                          style: AppTextStyles.labelStatus12w500.copyWith(
                            color: AppColors.gray400,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // 2. [이미지 미리보기] 선택된 이미지들이 나열되는 영역
              final imageIndex = index - 1;
              return Stack(
                children: [
                  // 로컬 경로의 파일을 FileImage로 렌더링
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: FileImage(File(imageUrls[imageIndex])),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),

                  // [삭제 버튼] 이미지 우측 상단의 X 버튼
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () =>
                          viewModel.removeImage(imageIndex), // 인덱스 기반 삭제
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          size: 16,
                          color: AppColors.gray700,
                        ),
                      ),
                    ),
                  ),

                  // 첫 번째 이미지(index 0)에만 '대표' 표시
                  if (imageIndex == 0)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primary900.withValues(alpha: 0.8),
                          borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(10),
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: const Text(
                          '대표',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),

        //  대표 사진 설명
        const SizedBox(height: 12),
        Text(
          '* 첫 번째 사진이 대표 사진입니다.',
          style: AppTextStyles.labelStatus12w500.copyWith(
            color: AppColors.gray300,
          ),
        ),
      ],
    );
  }
}
