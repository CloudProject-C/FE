import 'package:campit_frontend/feature/map/restaurant_detail_screen.dart';
import 'package:campit_frontend/shared/constants/app_text_styles.dart';
import 'package:campit_frontend/shared/ui/buttons/primary_button.dart';
import 'package:campit_frontend/shared/ui/buttons/secondary_button.dart';
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
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: Column(
            children: [
              _dragHandle(),
              const SizedBox(height: 16),

              /// 스크롤 영역
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _restaurantHeader(restaurantInfo),
                      const SizedBox(height: 16),
                      _restaurantInfo(restaurantInfo),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              /// 버튼 영역
              Row(
                children: [
                  Expanded(
                    child: SecondaryButton(
                      text: '상세보기',
                      height: 48,
                      width: double.infinity,
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RestaurantDetailScreen(
                              id: restaurantInfo['id'],
                              distance: restaurantInfo['distance'],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: PrimaryButton(
                      text: '리뷰 작성',
                      height: 48,
                      width: double.infinity,
                      onTap: () {
                        // TODO: 리뷰 작성 로직 연결
                      },
                    ),
                  ),
                ],
              ),
            ],
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


