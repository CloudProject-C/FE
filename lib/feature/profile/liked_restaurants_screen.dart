import 'package:flutter/material.dart';
import 'package:campit_frontend/shared/constants/app_colors.dart';
import 'package:campit_frontend/shared/constants/app_text_styles.dart';
import 'package:campit_frontend/shared/ui/bars/bottom_nav_bar.dart';
import 'package:campit_frontend/services/profile/profile_service.dart';

class LikedRestaurantsScreen extends StatefulWidget {
  const LikedRestaurantsScreen({super.key});

  @override
  State<LikedRestaurantsScreen> createState() =>
      _LikedRestaurantsScreenState();
}

class _LikedRestaurantsScreenState extends State<LikedRestaurantsScreen> {
  List<_LikedRestaurantVM> _restaurants = [];

  bool _loading = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _loadLikes();
  }

  Future<void> _loadLikes() async {
    setState(() {
      _loading = true;
      _error = false;
    });

    try {
      final data = await ProfileService.fetchMyLikes(
        page: 0,
        size: 50,
      );

      if (data == null || data['isSuccess'] != true) {
        setState(() {
          _loading = false;
          _error = true;
        });
        return;
      }

      final result = data['result'] as Map<String, dynamic>?;
      final content = (result?['content'] as List<dynamic>?) ?? [];

      final list = content.map((e) {
        final m = e as Map<String, dynamic>;
        final avg = m['averageRating'];
        double avgRating = 0.0;
        if (avg is int) avgRating = avg.toDouble();
        if (avg is double) avgRating = avg;

        return _LikedRestaurantVM(
          id: (m['placeId'] ?? 0) as int,
          name: (m['placeName'] ?? '').toString(),
          category: (m['categoryName'] ?? '').toString(),
          averageRating: avgRating,
          likeCount: (m['placeLikeCount'] ?? 0) as int,
          imageUrl: m['recentImageUrl']?.toString(),
        );
      }).toList();

      setState(() {
        _restaurants = list;
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _loading = false;
        _error = true;
      });
    }
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
                  child: _loading
                      ? const Center(child: CircularProgressIndicator())
                      : _error
                      ? Center(
                    child: Text(
                      '좋아요한 식당을 불러오지 못했습니다.',
                      style:
                      AppTextStyles.pretendard_regular.copyWith(
                        color: AppColors.grey_5,
                      ),
                    ),
                  )
                      : _restaurants.isEmpty
                      ? Center(
                    child: Text(
                      '좋아요한 식당이 없습니다.',
                      style: AppTextStyles.pretendard_regular
                          .copyWith(
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

class _LikedRestaurantVM {
  final int id;
  final String name;
  final String category;
  final double averageRating;
  final int likeCount;
  final String? imageUrl;

  _LikedRestaurantVM({
    required this.id,
    required this.name,
    required this.category,
    required this.averageRating,
    required this.likeCount,
    required this.imageUrl,
  });
}

class _LikedRestaurantCard extends StatelessWidget {
  final _LikedRestaurantVM restaurant;

  const _LikedRestaurantCard({
    required this.restaurant,
  });

  @override
  Widget build(BuildContext context) {
    final ratingInt = restaurant.averageRating.floor().clamp(0, 5);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: AppColors.grey_1,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 이름
              Text(
                restaurant.name,
                style: AppTextStyles.pretendard_medium.copyWith(
                  fontSize: 15,
                  color: AppColors.grey_8,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              // 별점
              const SizedBox(height: 2),
              Row(
                children: [
                  _StarRow(rating: ratingInt),
                  const SizedBox(width: 6),
                  Text(
                    restaurant.averageRating.toStringAsFixed(1),
                    style: AppTextStyles.pretendard_regular.copyWith(
                      fontSize: 13,
                      color: AppColors.grey_7,
                    ),
                  ),
                ],
              ),

              // 카테고리
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

              // 좋아요 수
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(
                    Icons.favorite,
                    size: 14,
                    color: AppColors.main,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    restaurant.likeCount.toString(),
                    style: AppTextStyles.pretendard_regular.copyWith(
                      fontSize: 12,
                      color: AppColors.grey_5,
                    ),
                  ),
                ],
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
    final safe = rating.clamp(0, 5);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final filled = index < safe;
        return Icon(
          filled ? Icons.star : Icons.star_border,
          size: 14,
          color: filled ? Colors.amber : AppColors.grey_3,
        );
      }),
    );
  }
}
