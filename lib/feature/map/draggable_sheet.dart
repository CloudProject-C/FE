import 'package:campit_frontend/feature/map/restaurant_detail_screen.dart';
import 'package:campit_frontend/services/map/map_service.dart';
import 'package:campit_frontend/shared/constants/app_text_styles.dart';
import 'package:campit_frontend/shared/ui/buttons/primary_button.dart';
import 'package:campit_frontend/shared/ui/buttons/secondary_button.dart';
import 'package:flutter/material.dart';
import '../../shared/constants/app_colors.dart';

class RestaurantBottomSheet extends StatefulWidget {
  final Map<String, dynamic> restaurantInfo;

  const RestaurantBottomSheet({
    super.key,
    required this.restaurantInfo,
  });

  @override
  State<RestaurantBottomSheet> createState() => _RestaurantBottomSheetState();
}

class _RestaurantBottomSheetState extends State<RestaurantBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.45,
      minChildSize: 0.3,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              _dragHandle(),
              const SizedBox(height: 20),

              /// 스크롤 영역
              Expanded(
                child: SingleChildScrollView(
                    controller: scrollController,
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. 이미지 영역
                          Container(
                            height: 110,
                            width: 110,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                widget.restaurantInfo['imageUrl'] ?? "",
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: AppColors.grey_1,
                                    child: const Icon(Icons.restaurant, color: Colors.grey),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),

                          // 2. 정보 영역
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // [수정] 상단: 이름 + 하트 아이콘 (여기에 클릭 이벤트 추가)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        widget.restaurantInfo['placeName'] ?? '-',
                                        style: AppTextStyles.pretendard_bold.copyWith(
                                          fontSize: 18,
                                          color: AppColors.grey_6,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 4),

                                    // [여기로 이동] 좋아요 클릭 로직
                                    GestureDetector(
                                      onTap: () async {
                                        final int id = widget.restaurantInfo['id'];
                                        final bool currentStatus = widget.restaurantInfo['isLiked'] ?? false;
                                        final int currentCount = widget.restaurantInfo['placeLikeCount'] ?? 0;

                                        // 1. UI 선반영 (Optimistic Update)
                                        setState(() {
                                          widget.restaurantInfo['isLiked'] = !currentStatus;
                                          // 좋아요 수 증감 처리
                                          widget.restaurantInfo['placeLikeCount'] = currentStatus
                                              ? currentCount - 1
                                              : currentCount + 1;
                                        });

                                        // 2. API 호출
                                        final success = await MapService.toggleLike(id);

                                        // 3. 실패 시 롤백
                                        if (!success) {
                                          if (!mounted) return;
                                          setState(() {
                                            widget.restaurantInfo['isLiked'] = currentStatus;
                                            widget.restaurantInfo['placeLikeCount'] = currentCount;
                                          });
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(content: Text('좋아요 처리에 실패했습니다.')),
                                          );
                                        }
                                      },
                                      behavior: HitTestBehavior.opaque, // 터치 영역 확보
                                      child: Icon(
                                        (widget.restaurantInfo['isLiked'] ?? false)
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color: (widget.restaurantInfo['isLiked'] ?? false)
                                            ? AppColors.main
                                            : AppColors.grey_4,
                                        size: 24,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 6),

                                // 카테고리
                                Text(
                                  widget.restaurantInfo['categoryName'] ?? '기타',
                                  style: AppTextStyles.pretendard_medium.copyWith(
                                    fontSize: 13,
                                    color: AppColors.grey_4,
                                  ),
                                ),

                                const SizedBox(height: 8),

                                // 매칭률 배지
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.main.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    "내 취향 ${(widget.restaurantInfo['preferencePercent'] ?? 0).toString()}% 일치",
                                    style: AppTextStyles.pretendard_bold.copyWith(
                                      fontSize: 12,
                                      color: AppColors.main,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 8),

                                // [수정] 통계 정보 (별점, 리뷰, 거리, 좋아요 수) - 여기는 단순 표시만
                                Row(
                                  children: [
                                    // 1. 별점 (Star)
                                    const Icon(Icons.star, size: 14, color: Colors.amber),
                                    const SizedBox(width: 2),
                                    Text(
                                      (widget.restaurantInfo['rating'] ?? 0).toStringAsFixed(1),
                                      style: AppTextStyles.pretendard_medium.copyWith(fontSize: 12, color: AppColors.grey_5),
                                    ),
                                    const SizedBox(width: 8),

                                    // 2. 리뷰 수 (Chat Bubble)
                                    Icon(Icons.chat_bubble_outline, size: 14, color: AppColors.grey_4),
                                    const SizedBox(width: 2),
                                    Text(
                                      "${widget.restaurantInfo['reviewCount'] ?? 0}",
                                      style: AppTextStyles.pretendard_medium.copyWith(fontSize: 12, color: AppColors.grey_5),
                                    ),
                                    const SizedBox(width: 8),

                                    // 3. 좋아요 수 (Heart) - 클릭 기능 제거됨 (단순 표시)
                                    Icon(
                                      (widget.restaurantInfo['isLiked'] ?? false) ? Icons.favorite : Icons.favorite_border,
                                      size: 14,
                                      color: (widget.restaurantInfo['isLiked'] ?? false) ? AppColors.main : AppColors.grey_4,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      "${widget.restaurantInfo['placeLikeCount'] ?? 0}",
                                      style: AppTextStyles.pretendard_medium.copyWith(
                                          fontSize: 12,
                                          color: (widget.restaurantInfo['isLiked'] ?? false) ? AppColors.main : AppColors.grey_5
                                      ),
                                    ),

                                    const SizedBox(width: 8),

                                    // 4. 거리 (Location)
                                    Icon(Icons.location_on_outlined, size: 14, color: AppColors.grey_4),
                                    const SizedBox(width: 2),
                                    Text(
                                      "${widget.restaurantInfo['distance']}m",
                                      style: AppTextStyles.pretendard_medium.copyWith(fontSize: 12, color: AppColors.grey_5),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ]
                    )
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
                              id: widget.restaurantInfo['id'],
                              distance: widget.restaurantInfo['distance'],
                              imageUrl: widget.restaurantInfo['imageUrl'] ?? "",
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: PrimaryButton(
                      text: '길찾기',
                      height: 48,
                      width: double.infinity,
                      onTap: () {
                        // TODO: 길찾기 로직 연결
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
}