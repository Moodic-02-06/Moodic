import 'package:flutter/material.dart';
import 'package:flutter_moodic/core/theme/app_color.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 90,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.primary900,
        border: Border(top: BorderSide(color: AppColors.gray100, width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildNavItem(index: 0, icon: Icons.home_filled),
          _buildNavItem(index: 1, icon: Icons.search),
          GestureDetector(
            onTap: () => onTap(2),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: ShapeDecoration(
                color: AppColors.secondary500,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(48),
                ),
                shadows: [
                  BoxShadow(
                    color: AppColors.secondary400.withValues(alpha: 0.5),
                    blurRadius: 20,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
              child: const Icon(
                Icons.add,
                size: 32,
                color: AppColors.primary900,
              ),
            ),
          ),

          // 오른쪽 아이템들
          _buildNavItem(index: 3, icon: Icons.favorite),
          _buildNavItem(index: 4, icon: Icons.person), // 마이페이지
        ],
      ),
    );
  }

  Widget _buildNavItem({required int index, required IconData icon}) {
    // GoRouter의 navigationShell.currentIndex와 비교하여 색상 변경

    final isSelected = currentIndex == index;
    return IconButton(
      onPressed: () => onTap(index),
      icon: Icon(
        icon,
        size: 28,
        color: isSelected ? AppColors.secondary500 : AppColors.gray500,
      ),
    );
  }
}
