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
  ReviewSortType _sortType = ReviewSortType.latest;

  @override
  void initState() {
    super.initState();
    //TODO: 더미 데이터 (나중에 API 연동 시 교체)
    _reviews = [
      _Review(
        id: '1',
        placeName: '플립브런치',
        rating: 4, 
        content:
            '빵이 정말 맛있어요. 다만 커피의 질이 조금 아쉬운것 같습니다. 다음에 또 올 것 같아요!',
        likes: 8,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
      _Review(
        id: '2',
        placeName: '경희떡볶이',
        rating: 5,
        content: '오래된 맛집이에요. 사장님도 친절하시고 가성비 최고입니다.',
        likes: 20,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ];
  }

  List<_Review> get _sortedReviews {
    final list = [..._reviews];
    switch (_sortType) {
      case ReviewSortType.latest:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case ReviewSortType.oldest:
        list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
      case ReviewSortType.likes:
        list.sort((a, b) => b.likes.compareTo(a.likes));
        break;
      case ReviewSortType.ratingHigh:
        list.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case ReviewSortType.ratingLow:
        list.sort((a, b) => a.rating.compareTo(b.rating));
        break;
    }
    return list;
  }

  String _formatTimeAgo(DateTime createdAt) {
    final diffDays = DateTime.now().difference(createdAt).inDays;
    if (diffDays <= 0) return '오늘';
    return '${diffDays}일 전';
  }

  String _sortLabel(ReviewSortType type) {
    switch (type) {
      case ReviewSortType.latest:
        return '최신순';
      case ReviewSortType.likes:
        return '좋아요순';
      case ReviewSortType.oldest:
        return '오래된순';
      case ReviewSortType.ratingHigh:
        return '별점높은순';
      case ReviewSortType.ratingLow:
        return '별점낮은순';
    }
  }

  Future<void> _confirmDelete(_Review review) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '리뷰 삭제',
                    style: AppTextStyles.pretendard_bold.copyWith(
                      fontSize: 16,
                      color: AppColors.grey_8,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '리뷰를 삭제하시겠습니까?\n삭제된 리뷰는 복구할 수 없습니다.',
                    textAlign: TextAlign.center,
                    style: AppTextStyles.pretendard_regular.copyWith(
                      fontSize: 13,
                      height: 1.4,
                      color: AppColors.grey_5,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.of(dialogContext).pop(false);
                          },
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            side: const BorderSide(color: AppColors.grey_3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                            padding:
                                const EdgeInsets.symmetric(vertical: 11),
                          ),
                          child: Text(
                            '취소',
                            style:
                                AppTextStyles.pretendard_medium.copyWith(
                              fontSize: 14,
                              color: AppColors.grey_7,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(dialogContext).pop(true);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.main,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                            padding:
                                const EdgeInsets.symmetric(vertical: 11),
                          ),
                          child: Text(
                            '삭제',
                            style:
                                AppTextStyles.pretendard_bold.copyWith(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (shouldDelete == true) {
      setState(() {
        _reviews.removeWhere((r) => r.id == review.id);
        //TODO: 백엔드 연동 후 서버에도 해당 리뷰 삭제 요청 보내고, 프로필 화면의 리뷰 개수와도 동기화하기
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final reviews = _sortedReviews;

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
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 정렬 드롭다운
                Align(
                  alignment: Alignment.centerLeft,
                  child: Theme(
                    data: Theme.of(context).copyWith(
                      popupMenuTheme: const PopupMenuThemeData(
                        color: Colors.white,
                        surfaceTintColor: Colors.white,
                      ),
                    ),
                    child: PopupMenuButton<ReviewSortType>(
                      onSelected: (value) {
                        setState(() {
                          _sortType = value;
                        });
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                          value: ReviewSortType.latest,
                          child: Text('최신순'),
                        ),
                        PopupMenuItem(
                          value: ReviewSortType.likes,
                          child: Text('좋아요순'),
                        ),
                        PopupMenuItem(
                          value: ReviewSortType.oldest,
                          child: Text('오래된순'),
                        ),
                        PopupMenuItem(
                          value: ReviewSortType.ratingHigh,
                          child: Text('별점높은순'),
                        ),
                        PopupMenuItem(
                          value: ReviewSortType.ratingLow,
                          child: Text('별점낮은순'),
                        ),
                      ],
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.grey_3),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _sortLabel(_sortType),
                              style: AppTextStyles.pretendard_regular.copyWith(
                                fontSize: 13,
                                color: AppColors.grey_7,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.arrow_drop_down,
                              size: 18,
                              color: AppColors.grey_7,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // 리뷰 리스트
                Expanded(
                  child: reviews.isEmpty
                      ? Center(
                    child: Text(
                      '작성한 리뷰가 없습니다.',
                      style: AppTextStyles.pretendard_regular.copyWith(
                        color: AppColors.grey_5,
                      ),
                    ),
                  )
                      : ListView.separated(
                    itemCount: reviews.length,
                    separatorBuilder: (_, __) =>
                    const SizedBox(height: 24),
                    itemBuilder: (context, index) {
                      final review = reviews[index];
                      return _ReviewCard(
                        review: review,
                        timeAgo: _formatTimeAgo(review.createdAt),
                        onDelete: () => _confirmDelete(review),
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

enum ReviewSortType {
  latest,
  likes,
  oldest,
  ratingHigh,
  ratingLow,
}

class _Review {
  final String id;
  final String placeName;
  final int rating; // 1~5, int만
  final String content;
  final int likes;
  final DateTime createdAt;

  _Review({
    required this.id,
    required this.placeName,
    required this.rating,
    required this.content,
    required this.likes,
    required this.createdAt,
  });
}

class _ReviewCard extends StatelessWidget {
  final _Review review;
  final String timeAgo;
  final VoidCallback onDelete;

  const _ReviewCard({
    required this.review,
    required this.timeAgo,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 작성 시간 + 삭제 버튼
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              timeAgo,
              style: AppTextStyles.pretendard_regular.copyWith(
                fontSize: 13,
                color: AppColors.grey_5,
              ),
            ),
            GestureDetector(
              onTap: onDelete,
              child: Text(
                '삭제',
                style: AppTextStyles.pretendard_regular.copyWith(
                  fontSize: 13,
                  color: AppColors.grey_5,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.grey_4,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // 이미지 + 가게 이름 + 별점
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 음식 이미지 (지금은 placeholder, 나중에 asset으로 교체)
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.grey_1,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.restaurant,
                color: AppColors.grey_5,
                size: 32,
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
                      color: AppColors.grey_8,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _StarRating(rating: review.rating),
                      const SizedBox(width: 6),
                      Text(
                        review.rating.toString(), // 4.5 대신 4, 5 이런 식
                        style: AppTextStyles.pretendard_regular.copyWith(
                          fontSize: 13,
                          color: AppColors.grey_7,
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
            color: AppColors.grey_7,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 8),

        // 좋아요
        Row(
          children: [
            const Icon(
              Icons.favorite_border,
              size: 18,
              color: AppColors.grey_5,
            ),
            const SizedBox(width: 4),
            Text(
              review.likes.toString(),
              style: AppTextStyles.pretendard_regular.copyWith(
                fontSize: 13,
                color: AppColors.grey_7,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StarRating extends StatelessWidget {
  final int rating; // 1~5

  const _StarRating({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(5, (index) {
        final filled = index < rating;
        return Padding(
          padding: EdgeInsets.only(right: index == 4 ? 0 : 0.0),
          child: Icon(
            filled ? Icons.star : Icons.star_border,
            size: 15,
            color: filled ? Colors.amber : AppColors.grey_3,
          ),
        );
      }),
    );
  }
}
