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

        final rawImage = m['recentImageUrl']?.toString();
        String? imageUrl;
        if (rawImage != null &&
            rawImage.isNotEmpty &&
            rawImage != 'exampleImageUrl') {
          imageUrl = rawImage;
        } else {
          imageUrl = null;
        }

        return _LikedRestaurantVM(
          id: (m['placeId'] ?? 0) as int,
          name: (m['placeName'] ?? '').toString(),
          category: (m['categoryName'] ?? '').toString(),
          averageRating: avgRating,
          likeCount: (m['placeLikeCount'] ?? 0) as int,
          imageUrl: imageUrl,
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
    return Scaffold(
      backgroundColor: AppColors.white,
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
            fontSize: 24,
            color: AppColors.grey_8,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Column(
            children: [
              const SizedBox(height: 28),
              Container(
                height: 1,
                color: AppColors.grey_2,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(
        currentRoute: '/profile',
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 40, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _error
                    ? Center(
                  child: Text(
                    '좋아요한 식당을 불러오지 못했습니다.',
                    style: AppTextStyles.pretendard_regular.copyWith(
                      color: AppColors.grey_5,
                      fontSize: 14,
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
                      fontSize: 14,
                    ),
                  ),
                )
                    : ListView.separated(
                  itemCount: _restaurants.length,
                  separatorBuilder: (_, __) =>
                  const SizedBox(height: 40),
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

  bool _isValidNetworkUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    return url.startsWith('http://') || url.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    final ratingInt = restaurant.averageRating.floor().clamp(0, 5);
    final imageUrl = restaurant.imageUrl;
    final hasValidImage = _isValidNetworkUrl(imageUrl);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 96,
                height: 96,
                color: AppColors.grey_2,
                child: hasValidImage
                    ? Image.network(
                  imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                  const SizedBox.shrink(),
                )
                    : const SizedBox.shrink(),
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: SizedBox(
                height: 96,
                child: Padding(
                  padding: const EdgeInsets.only(top: 18),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              restaurant.name,
                              style: AppTextStyles.pretendard_medium.copyWith(
                                fontSize: 16,
                                color: AppColors.grey_8,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            restaurant.category,
                            style: AppTextStyles.pretendard_regular.copyWith(
                              fontSize: 14,
                              color: AppColors.grey_5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _StarRow(rating: ratingInt),
                          const SizedBox(width: 8),
                          Text(
                            restaurant.averageRating
                                .toStringAsFixed(1)
                                .replaceFirst(RegExp(r'\.0$'), ''),
                            style: AppTextStyles.pretendard_regular.copyWith(
                              fontSize: 14,
                              color: AppColors.grey_7,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            const Icon(
              Icons.favorite,
              size: 20,
              color: AppColors.main,
            ),
            const SizedBox(width: 6),
            Text(
              restaurant.likeCount.toString(),
              style: AppTextStyles.pretendard_regular.copyWith(
                fontSize: 14,
                color: AppColors.grey_5,
              ),
            ),
          ],
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
          size: 22,
          color: filled ? Colors.amber : AppColors.grey_3,
        );
      }),
    );
  }
}
