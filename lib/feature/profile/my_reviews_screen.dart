import 'package:flutter/material.dart';
import 'package:campit_frontend/shared/constants/app_colors.dart';
import 'package:campit_frontend/shared/constants/app_text_styles.dart';
import 'package:campit_frontend/shared/ui/bars/bottom_nav_bar.dart';
import 'package:campit_frontend/services/profile/profile_service.dart';

class MyReviewsScreen extends StatefulWidget {
  const MyReviewsScreen({super.key});

  @override
  State<MyReviewsScreen> createState() => _MyReviewsScreenState();
}

class _MyReviewsScreenState extends State<MyReviewsScreen> {
  List<_ReviewVM> _reviews = [];

  /// 드롭다운
  String _selectedSort = '최신순';

  bool _loading = true;
  bool _error = false;

  static const List<String> _sortLabels = [
    '최신순',
    '좋아요순',
    '오래된순',
    '별점높은순',
    '별점낮은순',
  ];

  String _toSortCode(String label) {
    switch (label) {
      case '최신순':
        return 'LATEST';
      case '좋아요순':
        return 'LIKES';
      case '오래된순':
        return 'OLDEST';
      case '별점높은순':
        return 'RATING_HIGH';
      case '별점낮은순':
        return 'RATING_LOW';
      default:
        return 'LATEST';
    }
  }

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() {
      _loading = true;
      _error = false;
    });

    try {
      final data = await ProfileService.fetchMyReviews(
        sort: _toSortCode(_selectedSort),
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
        return _ReviewVM(
          id: (m['reviewId'] ?? 0) as int,
          restaurantName: (m['placeName'] ?? '').toString(),
          rating: (m['rating'] ?? 0) as int,
          content: (m['content'] ?? '').toString(),
          likes: (m['likeCount'] ?? 0) as int,
          imageUrl: m['representativeImageUrl']?.toString(),
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

  /// 드롭다운 변경 시
  void _changeSort(String? value) {
    if (value == null) return;
    setState(() {
      _selectedSort = value;
    });
    _loadReviews();
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
                // 상단 정렬 드롭다운
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    height: 30,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.main,
                        width: 1,
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedSort,
                        isDense: true,
                        iconSize: 16,
                        icon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 16,
                          color: AppColors.main,
                        ),
                        dropdownColor: AppColors.white,
                        style: AppTextStyles.pretendard_regular.copyWith(
                          fontSize: 12,
                          color: AppColors.main,
                        ),
                        items: _sortLabels
                            .map(
                              (label) => DropdownMenuItem(
                            value: label,
                            child: Text(label),
                          ),
                        )
                            .toList(),
                        onChanged: _changeSort,
                      ),
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
                      '리뷰를 불러오지 못했습니다.',
                      style:
                      AppTextStyles.pretendard_regular.copyWith(
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
                      return _ReviewTile(review: review);
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

class _ReviewVM {
  final int id;
  final String restaurantName;
  final int rating;
  final String content;
  final int likes;
  final String? imageUrl;

  _ReviewVM({
    required this.id,
    required this.restaurantName,
    required this.rating,
    required this.content,
    required this.likes,
    required this.imageUrl,
  });
}

class _ReviewTile extends StatelessWidget {
  final _ReviewVM review;

  const _ReviewTile({
    required this.review,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '',
              style: AppTextStyles.pretendard_regular.copyWith(
                fontSize: 13,
                color: AppColors.grey_5,
              ),
            ),
            const Spacer(),
          ],
        ),
        const SizedBox(height: 8),

        // 이미지 + 가게 이름 / 별점
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 음식 사진
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 80,
                height: 80,
                color: AppColors.grey_2,
              ),
            ),
            const SizedBox(width: 12),

            // 오른쪽: 가게 이름 + 별점만
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    review.restaurantName,
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
                      _StarRow(rating: review.rating),
                      const SizedBox(width: 6),
                      Text(
                        review.rating.toString(),
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

        // 리뷰 내용
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

        // 하트 + 좋아요 수
        Row(
          children: [
            const Icon(
              Icons.favorite_border,
              size: 16,
              color: AppColors.grey_4,
            ),
            const SizedBox(width: 4),
            Text(
              review.likes.toString(),
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
