import 'package:flutter/material.dart';
import 'package:campit_frontend/shared/constants/app_colors.dart';
import 'package:campit_frontend/shared/constants/app_text_styles.dart';
import 'package:campit_frontend/shared/ui/bars/bottom_nav_bar.dart';

class LikedRestaurantsScreen extends StatefulWidget {
  const LikedRestaurantsScreen({super.key});

  @override
  State<LikedRestaurantsScreen> createState() =>
      _LikedRestaurantsScreenState();
}

class _LikedRestaurantsScreenState extends State<LikedRestaurantsScreen> {
  late List<_LikedRestaurant> _restaurants;

  @override
  void initState() {
    super.initState();
    // TODO: 백엔드 연동 후 서버에서 실제 좋아요한 식당 목록을 불러오도록 수정
    _restaurants = [
      _LikedRestaurant(
        id: '1',
        name: '플립브런치',
        category: '브런치 · 카페',
        rating: 4,
      ),
      _LikedRestaurant(
        id: '2',
        name: '경희떡볶이',
        category: '분식',
        rating: 5,
      ),
      _LikedRestaurant(
        id: '3',
        name: '청년다방',
        category: '분식 · 떡볶이',
        rating: 4,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final count = _restaurants.length;

    return Scaffold(
      backgroundColor: AppColors.grey_1,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: AppColors.grey_7,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '좋아요한 식당',
          style: AppTextStyles.pretendard_bold.copyWith(
            fontSize: 18,
            color: AppColors.grey_8,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: AppColors.grey_2,
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(
        currentRoute: '/profile',
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 상단 "좋아요한 식당 / 총 n개"
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '좋아요한 식당',
                      style: AppTextStyles.pretendard_bold.copyWith(
                        fontSize: 15,
                        color: AppColors.grey_8,
                      ),
                    ),
                    Text(
                      '총 $count개',
                      style: AppTextStyles.pretendard_regular.copyWith(
                        fontSize: 13,
                        color: AppColors.grey_5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                Expanded(
                  child: _restaurants.isEmpty
                      ? Center(
                    child: Text(
                      '좋아요한 식당이 없습니다.',
                      style: AppTextStyles.pretendard_regular.copyWith(
                        color: AppColors.grey_5,
                      ),
                    ),
                  )
                      : ListView.separated(
                    itemCount: _restaurants.length,
                    separatorBuilder: (_, __) =>
                    const SizedBox(height: 20),
                    itemBuilder: (context, index) {
                      final restaurant = _restaurants[index];
                      return _LikedRestaurantCard(
                        restaurant: restaurant,
                        onUnlike: () {
                          // TODO: 백엔드 연동 후 서버에도 좋아요 취소 요청 보내기
                          setState(() {
                            _restaurants.removeWhere(
                                    (r) => r.id == restaurant.id);
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LikedRestaurant {
  final String id;
  final String name;
  final String category;
  final int rating;

  _LikedRestaurant({
    required this.id,
    required this.name,
    required this.category,
    required this.rating,
  });
}

class _LikedRestaurantCard extends StatelessWidget {
  final _LikedRestaurant restaurant;
  final VoidCallback onUnlike;

  const _LikedRestaurantCard({
    required this.restaurant,
    required this.onUnlike,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 왼쪽 썸네일 (작성한 리뷰 레이아웃과 유사)
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: AppColors.grey_1,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.restaurant,
            size: 32,
            color: AppColors.grey_5,
          ),
        ),
        const SizedBox(width: 12),

        // 오른쪽 정보 영역
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 이름 + 하트
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      restaurant.name,
                      style: AppTextStyles.pretendard_medium.copyWith(
                        fontSize: 15,
                        color: AppColors.grey_8,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: onUnlike,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(
                      Icons.favorite,
                      size: 20,
                      color: AppColors.main,
                    ),
                  ),
                ],
              ),

              // 이름 바로 아래에 별점
              const SizedBox(height: 2),
              Row(
                children: [
                  _StarRow(rating: restaurant.rating),
                  const SizedBox(width: 6),
                  Text(
                    restaurant.rating.toString(),
                    style: AppTextStyles.pretendard_regular.copyWith(
                      fontSize: 13,
                      color: AppColors.grey_7,
                    ),
                  ),
                ],
              ),

              // 그 아래에 카테고리
              const SizedBox(height: 6),
              Text(
                restaurant.category,
                style: AppTextStyles.pretendard_regular.copyWith(
                  fontSize: 13,
                  color: AppColors.grey_6,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StarRow extends StatelessWidget {
  final int rating;

  const _StarRow({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final filled = index < rating;
        return Icon(
          filled ? Icons.star : Icons.star_border,
          size: 14,
          color: filled ? Colors.amber : AppColors.grey_3,
        );
      }),
    );
  }
}
