import 'package:campit_frontend/feature/map/restaurant_detail_screen.dart';
import 'package:campit_frontend/shared/constants/app_assets.dart';
import 'package:flutter/material.dart';
import 'package:campit_frontend/shared/constants/app_colors.dart';
import 'package:campit_frontend/shared/constants/app_text_styles.dart';
import 'package:campit_frontend/services/map/map_service.dart';
import 'dart:math';
import 'package:geolocator/geolocator.dart';

class ListScreen extends StatefulWidget {
  final String? category;
  final String sort;

  const ListScreen({
    super.key,
    required this.category,
    required this.sort,
  });

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _restaurants = [];

  @override
  void initState() {
    super.initState();
    _loadRestaurants();
  }

  // [추가] 부모 위젯에서 전달받은 category가 바뀌면 호출됨
  @override
  void didUpdateWidget(covariant ListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    // 카테고리가 변경되었다면 다시 로드
    if (widget.category != oldWidget.category) {
      print("리스트 화면 카테고리 변경: ${oldWidget.category} -> ${widget.category}");
      _loadRestaurants();
    }

    // 카테고리가 변경되었다면 다시 로드
    if (widget.sort != oldWidget.sort) {
      print("리스트 화면 정렬방식 변경: ${oldWidget.sort} -> ${widget.sort}");
      _loadRestaurants();
    }
  }

  Future<void> _loadRestaurants() async {

    // 1. 위치 권한 확인 및 요청
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // 권한 거부됨 -> 기본 위치(예: 서울역)나 에러 처리
        print('위치 권한이 거부되었습니다.');
        setState(() => _loading = false);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // 권한 영구 거부됨 -> 설정으로 유도하거나 에러 처리
      print('위치 권한이 영구적으로 거부되었습니다.');
      setState(() => _loading = false);
      return;
    }

    // 2. 현재 위치 가져오기
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    print("현재 위치: ${position.latitude}, ${position.longitude}");
    // 현재 위치 없이 임의 좌표로 테스트

    final data = await MapService.fetchRestaurants(
      position.latitude,
      position.longitude,
      category: widget.category, // 전달받은 카테고리 적용
      sort: widget.sort
    );

    print(data);

    if(data == null) return;

    if (!mounted) return;
    setState(() {
      _restaurants = data.map((r) {
        return {
          ...r,
          "id": r["placeId"],
          "placeName": r["placeName"],
          "genre": r["categoryName"],
          "distance": r["distance"],
          "likes": r["placeLikeCount"],
          "reviews": r["reviewCount"],
          "match": r["preferencePercent"], // 80~99%
          //"isLiked": r["isLiked"],
          "rating": r["rating"],
        };
      }).toList();

      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    print(" length of restaurant is: ${_restaurants.length}");
    return Container(
      color: AppColors.white,
      child: _loading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        itemCount: _restaurants.length,
        itemBuilder: (context, index) {
          final item = _restaurants[index];
          return _restaurantCard(item);
        },
      ),
    );
  }

  Widget _restaurantCard(Map<String, dynamic> item) {
    return InkWell(
      onTap: (){
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RestaurantDetailScreen(
              id: item['id'],
              distance: item['distance'],
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.grey_4.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 상단 (가게명 + 매칭률)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    item["placeName"],
                    style: AppTextStyles.pretendard_regular.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.grey_5,
                    ),
                  ),
                ),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.main_50per,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "${item['match']}%",
                    style: AppTextStyles.pretendard_regular.copyWith(
                      color: AppColors.white,
                      fontSize: 14,
                    ),
                  ),
                )
              ],
            ),

            const SizedBox(height: 6),

            /// 음식 장르
            Text(
              item["genre"],
              style: AppTextStyles.pretendard_regular.copyWith(
                color: AppColors.grey_4,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 8),

            /// 위치 아이콘 + 거리
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  color: AppColors.grey_4,
                  size: 18,
                ),
                const SizedBox(width: 4),
                Text(
                  item["distance"].toString(),
                  style: AppTextStyles.pretendard_regular.copyWith(
                    color: AppColors.grey_4,
                    fontSize: 13,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            /// 좋아요 + 리뷰 + 별점
            Row(
              children: [
                Icon(Icons.favorite_border,
                    color: AppColors.grey_4, size: 18),
                const SizedBox(width: 4),
                Text(
                  "${item['likes']}",
                  style: AppTextStyles.pretendard_regular.copyWith(
                    fontSize: 13,
                    color: AppColors.grey_4,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(Icons.chat_bubble_outline,
                    color: AppColors.grey_4, size: 18),
                const SizedBox(width: 4),
                Text(
                  "${item['reviews']}",
                  style: AppTextStyles.pretendard_regular.copyWith(
                    fontSize: 13,
                    color: AppColors.grey_4,
                  ),
                ),
                const SizedBox(width: 16), // 간격

                // 3. 별점 (Rating)
                const Icon(Icons.star, color: Colors.amber, size: 18), // 노란색 별
                const SizedBox(width: 4),
                Text(
                  "${item['rating']}", // 점수 표시 (예: 4.5)
                  style: AppTextStyles.pretendard_regular.copyWith(
                    fontSize: 13,
                    color: AppColors.grey_4,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
