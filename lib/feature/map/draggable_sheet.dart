import 'package:campit_frontend/shared/constants/app_text_styles.dart';
import 'package:flutter/material.dart';
import '../../shared/constants/app_colors.dart';

class RestaurantBottomSheet extends StatelessWidget {
  final Map<String, dynamic> restaurantInfo;

  const RestaurantBottomSheet({
    required this.restaurantInfo,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5, // 처음에 화면의 50%
      minChildSize: 0.3,     // 최소
      maxChildSize: 0.9,     // 거의 풀스크린
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                _dragHandle(),
                const SizedBox(height: 16),
                _restaurantHeader(restaurantInfo),
                const SizedBox(height: 16),
                _restaurantInfo(restaurantInfo),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _dragHandle() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.grey_3,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _restaurantHeader(Map<String, dynamic> info) {
    return Text(
      info['placeName'] ?? '-',
      style: AppTextStyles.pretendard_medium.copyWith(
        fontSize: 20,
        color: AppColors.grey_6,
      ),
    );
  }


  Widget _restaurantInfo(Map<String, dynamic> info) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '카테고리: ${info['categoryName'] ?? '-'}',
          style: AppTextStyles.pretendard_medium.copyWith(
            fontSize: 14,
            color: AppColors.grey_4,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '거리: ${info['distance']}m',
          style: AppTextStyles.pretendard_medium.copyWith(
            fontSize: 14,
            color: AppColors.grey_4,
          ),
        ),
      ],
    );
  }

}


