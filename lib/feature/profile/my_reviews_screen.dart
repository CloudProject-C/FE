import 'package:flutter/material.dart';
import 'package:campit_frontend/shared/constants/app_colors.dart';
import 'package:campit_frontend/shared/constants/app_text_styles.dart';
import 'package:campit_frontend/shared/ui/bars/bottom_nav_bar.dart';

class MyReviewsScreen extends StatefulWidget {
  const MyReviewsScreen({super.key});

  @override
  State<MyReviewsScreen> createState() => _MyReviewsScreenState();
}

class _MyReviewsScreenState extends State<MyReviewsScreen> {
  late List<_Review> _reviews;

  /// 드롭다운 선택값
  String _selectedSort = '최신순';

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();

    // TODO: 백엔드 연동 후 실제 데이터로 교체
    _reviews = [
      _Review(
        id: 1,
        restaurantName: '플립브런치',
        rating: 4,
        createdAt: now.subtract(const Duration(days: 1)), // 1일 전
        content:
        '빵이 정말 맛있어요. 다만 커피의 질이 조금 아쉬운 것 같습니다. 다음에 또 올 것 같아요!',
        likes: 8,
      ),
      _Review(
        id: 2,
        restaurantName: '경희떡볶이',
        rating: 5,
        createdAt: now.subtract(const Duration(days: 2)), // 2일 전
        content: '오래된 맛집이에요. 사장님도 친절하시고 가성비 최고입니다.',
        likes: 20,
      ),
    ];

    _sortReviews(); // 기본값: 최신순
  }

  /// 정렬 기준에 따라 리스트 정렬
  void _sortReviews() {
    _reviews.sort((a, b) {
      switch (_selectedSort) {
        case '최신순':
        // 최근 날짜 먼저
          return b.createdAt.compareTo(a.createdAt);
        case '좋아요순':
        // 좋아요 많은 순, 같으면 최신순
          final likeDiff = b.likes.compareTo(a.likes);
          if (likeDiff != 0) return likeDiff;
          return b.createdAt.compareTo(a.createdAt);
        case '오래된순':
        // 오래된 날짜 먼저
          return a.createdAt.compareTo(b.createdAt);
        case '별점높은순':
        // 별점 높은 순, 같으면 최신순
          final ratingDiff = b.rating.compareTo(a.rating);
          if (ratingDiff != 0) return ratingDiff;
          return b.createdAt.compareTo(a.createdAt);
        case '별점낮은순':
        // 별점 낮은 순, 같으면 오래된순
          final ratingDiff = a.rating.compareTo(b.rating);
          if (ratingDiff != 0) return ratingDiff;
          return a.createdAt.compareTo(b.createdAt);
        default:
          return 0;
      }
    });
  }

  /// 드롭다운 변경 시
  void _changeSort(String? value) {
    if (value == null) return;
    setState(() {
      _selectedSort = value;
      _sortReviews();
    });
  }

  void _deleteReview(_Review review) {
    // TODO: 백엔드 연동 후 서버 삭제 로직 추가
    setState(() {
      _reviews.removeWhere((r) => r.id == review.id);
    });
  }

  String _formatDaysAgo(DateTime date) {
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
                        items: const [
                          DropdownMenuItem(
                            value: '최신순',
                            child: Text('최신순'),
                          ),
                          DropdownMenuItem(
                            value: '좋아요순',
                            child: Text('좋아요순'),
                          ),
                          DropdownMenuItem(
                            value: '오래된순',
                            child: Text('오래된순'),
                          ),
                          DropdownMenuItem(
                            value: '별점높은순',
                            child: Text('별점높은순'),
                          ),
                          DropdownMenuItem(
                            value: '별점낮은순',
                            child: Text('별점낮은순'),
                          ),
                        ],
                        onChanged: _changeSort,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 리뷰 리스트
                Expanded(
                  child: _reviews.isEmpty
                      ? Center(
                    child: Text(
                      '작성한 리뷰가 없습니다.',
                      style: AppTextStyles.pretendard_regular.copyWith(
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
                        daysAgoText: _formatDaysAgo(review.createdAt),
                        onDelete: () => _deleteReview(review),
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

class _Review {
  final int id;
  final String restaurantName;
  final int rating;
  final DateTime createdAt;
  final String content;
  final int likes;

  _Review({
    required this.id,
    required this.restaurantName,
    required this.rating,
    required this.createdAt,
    required this.content,
    required this.likes,
  });
}
class _ReviewTile extends StatelessWidget {
  final _Review review;
  final String daysAgoText;
  final VoidCallback onDelete;

  const _ReviewTile({
    required this.review,
    required this.daysAgoText,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // "1일 전" + "삭제"
        Row(
          children: [
            Text(
              daysAgoText,
              style: AppTextStyles.pretendard_regular.copyWith(
                fontSize: 13,
                color: AppColors.grey_5,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: onDelete,
              child: Text(
                '삭제',
                style: AppTextStyles.pretendard_regular.copyWith(
                  fontSize: 13,
                  color: AppColors.grey_4,
                ),
              ),
            ),
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

            // 가게 이름 + 별점
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 가게 이름
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

                  // 별점 + 점수
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

        // 하트 + 좋아요 수 (리뷰 아래)
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final filled = index < rating;
        return Icon(
          filled ? Icons.star : Icons.star_border,
          size: 16,
          color: Colors.amber,
        );
      }),
    );
  }
}
