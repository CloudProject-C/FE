import 'package:flutter/material.dart';
import 'package:campit_frontend/shared/constants/app_colors.dart';
import 'package:campit_frontend/shared/constants/app_text_styles.dart';
import 'package:campit_frontend/shared/ui/bars/bottom_nav_bar.dart';
import 'package:campit_frontend/shared/ui/custom_dropdown_filter.dart';
import 'package:campit_frontend/services/profile/profile_service.dart';

class MyReviewsScreen extends StatefulWidget {
  const MyReviewsScreen({super.key});

  @override
  State<MyReviewsScreen> createState() => _MyReviewsScreenState();
}

class _MyReviewsScreenState extends State<MyReviewsScreen> {
  List<_ReviewVM> _reviews = [];

  bool _loading = true;
  bool _error = false;

  String _selectedSort = '최신순';

  final List<String> _sortItems = const [
    '최신순',
    '좋아요순',
    '오래된순',
    '별점높은순',
    '별점낮은순',
  ];

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  String _toApiSort(String label) {
    switch (label) {
      case '최신순':
        return 'LATEST';
      case '오래된순':
        return 'OLDEST';
      case '별점높은순':
        return 'RATING_HIGH';
      case '별점낮은순':
        return 'RATING_LOW';
      case '좋아요순':
        return 'LIKES';
      default:
        return 'LATEST';
    }
  }

  Future<void> _loadReviews() async {
    setState(() {
      _loading = true;
      _error = false;
    });

    try {
      final data = await ProfileService.fetchMyReviews(
        sort: _toApiSort(_selectedSort),
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

        DateTime? createdAt;
        final rawCreatedAt =
            m['createdAt'] ?? m['createdDate'] ?? m['createdTime'];
        if (rawCreatedAt is String && rawCreatedAt.isNotEmpty) {
          try {
            createdAt = DateTime.parse(rawCreatedAt);
          } catch (_) {
            createdAt = null;
          }
        }

        return _ReviewVM(
          id: (m['reviewId'] ?? 0) as int,
          placeName: (m['placeName'] ?? '').toString(),
          rating: (m['rating'] ?? 0) as int,
          content: (m['content'] ?? '').toString(),
          imageUrl: m['representativeImageUrl']?.toString(),
          likeCount: (m['likeCount'] ?? 0) as int,
          createdAt: createdAt,
        );
      }).toList();

      setState(() {
        _reviews = list;
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _loading = false;
        _error = true;
      });
    }
  }

  void _changeSort(String value) {
    setState(() {
      _selectedSort = value;
    });
    _loadReviews();
  }

  String _formatDaysAgo(DateTime? date) {
    if (date == null) return '작성일 정보 없음';
    final diff = DateTime.now().difference(date).inDays;
    if (diff <= 0) return '오늘';
    return '${diff}일 전';
  }

  @override
  Widget build(BuildContext context) {
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
          '작성한 리뷰',
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
        child: Container(
          width: double.infinity,
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: SizedBox(
                  width: 140,
                  child: CustomDropdownFilter(
                    selected: _selectedSort,
                    items: _sortItems,
                    onSelected: _changeSort,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _error
                    ? Center(
                  child: Text(
                    '작성한 리뷰를 불러오지 못했습니다.',
                    style: AppTextStyles.pretendard_regular.copyWith(
                      color: AppColors.grey_5,
                    ),
                  ),
                )
                    : _reviews.isEmpty
                    ? Center(
                  child: Text(
                    '작성한 리뷰가 없습니다.',
                    style: AppTextStyles.pretendard_regular
                        .copyWith(
                      color: AppColors.grey_5,
                    ),
                  ),
                )
                    : ListView.separated(
                  itemCount: _reviews.length,
                  separatorBuilder: (_, __) =>
                  const SizedBox(height: 24),
                  itemBuilder: (context, index) {
                    final review = _reviews[index];
                    return _ReviewTile(
                      review: review,
                      daysAgoText: _formatDaysAgo(
                          review.createdAt),
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

class _ReviewVM {
  final int id;
  final String placeName;
  final int rating;
  final String content;
  final String? imageUrl;
  final int likeCount;
  final DateTime? createdAt;

  _ReviewVM({
    required this.id,
    required this.placeName,
    required this.rating,
    required this.content,
    required this.imageUrl,
    required this.likeCount,
    required this.createdAt,
  });
}

class _ReviewTile extends StatelessWidget {
  final _ReviewVM review;
  final String daysAgoText;

  const _ReviewTile({
    required this.review,
    required this.daysAgoText,
  });

  @override
  Widget build(BuildContext context) {
    final int roundedRating =
    (review.rating.toDouble()).round().clamp(0, 5);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          daysAgoText,
          style: AppTextStyles.pretendard_regular.copyWith(
            fontSize: 13,
            color: AppColors.grey_5,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 80,
                height: 80,
                color: AppColors.grey_2,
                child: (review.imageUrl != null &&
                    review.imageUrl!.isNotEmpty)
                    ? Image.network(
                  review.imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                  const SizedBox.shrink(),
                )
                    : const SizedBox.shrink(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    review.placeName,
                    style: AppTextStyles.pretendard_medium.copyWith(
                      fontSize: 15,
                      color: AppColors.grey_7,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _StarRow(rating: roundedRating),
                      const SizedBox(width: 6),
                      Text(
                        roundedRating.toString(),
                        style: AppTextStyles.pretendard_regular.copyWith(
                          fontSize: 13,
                          color: AppColors.grey_6,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          review.content,
          style: AppTextStyles.pretendard_regular.copyWith(
            fontSize: 13,
            color: AppColors.grey_6,
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(
              Icons.favorite_border,
              size: 16,
              color: AppColors.grey_4,
            ),
            const SizedBox(width: 4),
            Text(
              review.likeCount.toString(),
              style: AppTextStyles.pretendard_regular.copyWith(
                fontSize: 12,
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
          size: 16,
          color: Colors.amber,
        );
      }),
    );
  }
}
