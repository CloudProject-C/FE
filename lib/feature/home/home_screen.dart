import 'package:campit_frontend/feature/account/onboard_preference_screen.dart';
import 'package:campit_frontend/feature/map/restaurant_detail_screen.dart';
import 'package:campit_frontend/services/home/home_service.dart';
import 'package:campit_frontend/shared/constants/app_assets.dart';
import 'package:flutter/material.dart';
import 'package:campit_frontend/shared/constants/app_colors.dart';
import 'package:campit_frontend/shared/constants/app_text_styles.dart';
import 'package:campit_frontend/shared/ui/bars/bottom_nav_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  static const routeName = "/home";

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // [수정 1] Future 변수 선언
  late Future<Map<String, dynamic>?> _homeDataFuture;

  @override
  void initState() {
    super.initState();
    // [수정 2] 앱 시작 시(위젯 생성 시) 딱 한 번만 데이터 로드
    _homeDataFuture = HomeService.fetch_home_data();
  }

  // (선택 사항) 당겨서 새로고침 기능을 넣고 싶다면 아래 함수 사용
  Future<void> _refreshData() async {
    setState(() {
      _homeDataFuture = HomeService.fetch_home_data();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
        future: _homeDataFuture, // [수정 3] 변수에 저장된 Future 사용
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              backgroundColor: AppColors.white,
              body: Center(child: CircularProgressIndicator()),
              bottomNavigationBar: BottomNavBar(currentRoute: HomeScreen.routeName),
            );
          }

          if (snapshot.hasError) {
            debugPrint("Snapshot Error: ${snapshot.error}");
            return Scaffold(
              backgroundColor: AppColors.white,
              body: Center(child: Text('에러 발생: ${snapshot.error}')),
              bottomNavigationBar: BottomNavBar(currentRoute: HomeScreen.routeName),
            );
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Scaffold(
              backgroundColor: AppColors.white,
              body: Center(child: Text('데이터를 불러오지 못했습니다.')),
              bottomNavigationBar: BottomNavBar(currentRoute: HomeScreen.routeName),
            );
          }

          final result = snapshot.data!['result'];
          // ... (이하 데이터 파싱 로직 동일) ...
          final schoolName = result['schoolName'];
          final schoolUserCount = result['schoolUserCount'];
          final schoolReviewCount = result['schoolReviewCount'];
          final schoolPlaceCount = result['schoolPlaceCount'];
          final List<dynamic> recommendedPlaces = result['recommendedPlaces'] ?? [];

          return GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Scaffold(
              backgroundColor: AppColors.white,
              body: SafeArea(
                // [선택 사항] RefreshIndicator로 감싸면 당겨서 새로고침 가능
                child: RefreshIndicator(
                  onRefresh: _refreshData,
                  color: AppColors.main,
                  child: SingleChildScrollView(
                    // SingleChildScrollView에 physics 추가 (새로고침을 위해)
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        // 상단 영역 (로고 + 학교명)
                        Container(
                          width: double.infinity,
                          color: AppColors.main,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Image.asset(
                                    AppAssets.logo_white,
                                    height: 42,
                                  ),
                                  const SizedBox(width: 12),
                                  const SizedBox(width: 50),
                                  Expanded(
                                    child: Text(
                                      schoolName,
                                      style: AppTextStyles.pretendard_bold.copyWith(
                                        color: AppColors.white,
                                        fontSize: 17,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // 컨텐츠 영역
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),

                            StatisticsCard(
                                activeStudents: schoolUserCount,
                                reviewCount: schoolReviewCount,
                                restaurantCount: schoolPlaceCount
                            ),

                            const SizedBox(height: 30),

                            // 추천 식당 섹션
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Text(
                                '오늘의 추천 맛집 🍽️',
                                style: AppTextStyles.pretendard_bold.copyWith(
                                  fontSize: 18,
                                  color: AppColors.grey_6,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            if (recommendedPlaces.isEmpty)
                              Container(
                                height: 220,
                                width: double.infinity,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: AppColors.grey_1.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                margin: const EdgeInsets.symmetric(horizontal: 20),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.refresh, size: 32, color: AppColors.grey_4),
                                    const SizedBox(height: 12),
                                    Text(
                                      '화면을 당겨 새로고침해 주세요!',
                                      style: AppTextStyles.pretendard_medium.copyWith(
                                        color: AppColors.grey_5,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                              SizedBox(
                                height: 220,
                                child: ListView.separated(
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  scrollDirection: Axis.horizontal,
                                  itemCount: recommendedPlaces.length,
                                  separatorBuilder: (context, index) => const SizedBox(width: 16),
                                  itemBuilder: (context, index) {
                                    final place = recommendedPlaces[index];
                                    return _RecommendedPlaceCard(place: place);
                                  },
                                ),
                              ),

                            const SizedBox(height: 30),

                            // 소개 박스
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: AppColors.main.withOpacity(0.06),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: AppColors.main.withOpacity(0.25),
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'CampEat이란?',
                                            style: AppTextStyles.pretendard_bold.copyWith(
                                              color: AppColors.grey_5,
                                              fontSize: 18,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            '우리 학교 학생들만의 맛집 공유 플랫폼! 500m 인증을 통해 진짜 후기만 모아요. 내 취향에 맞는 맛집을 AI가 추천해드려요.',
                                            style: AppTextStyles.pretendard_medium.copyWith(
                                              color: AppColors.grey_5,
                                              height: 1.45,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 40), // 하단 여백
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 하단 네비게이션바
              bottomNavigationBar: BottomNavBar(
                currentRoute: HomeScreen.routeName,
              ),
            ),
          );
        }
    );
  }
}

// 추천 식당 카드 위젯
class _RecommendedPlaceCard extends StatelessWidget {
  final Map<String, dynamic> place;

  const _RecommendedPlaceCard({required this.place});

  @override
  Widget build(BuildContext context) {
    final placeId = place['placeId'];
    final imageUrl = place['recentImageUrl'] ?? "https://www.urbanbrush.net/web/wp-content/uploads/edd/2021/07/urbanbrush-20210720213004046257.jpg";
    final placeName = place['placeName'] ?? '이름 없음';
    final category = place['categoryName'] ?? '기타';
    final rating = place['averageRating'] ?? 0.0;
    final preference = place['preferencePercent'] ?? 0;
    final likeCount = place['placeLikeCount'] ?? 0;
    final isLiked = place['isLiked'] ?? false;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RestaurantDetailScreen(
              id: placeId,
              distance: 0, // 홈 화면에서는 거리를 알 수 없으므로 0 또는 적절한 기본값 전달
              imageUrl: imageUrl,
            ),
          ),
        );
      },
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.grey_4.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: AppColors.grey_2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이미지 영역
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: imageUrl != null
                  ? Image.network(
                imageUrl,
                height: 100,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 100,
                    color: AppColors.grey_2,
                    child: const Center(child: Icon(Icons.restaurant, color: AppColors.grey_4)),
                  );
                },
              )
                  : Container(
                height: 100,
                color: AppColors.grey_2,
                child: const Center(child: Icon(Icons.restaurant, color: AppColors.grey_4)),
              ),
            ),

            // 텍스트 정보 영역
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 카테고리 & 별점 & 좋아요
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          category,
                          style: AppTextStyles.pretendard_regular.copyWith(
                            fontSize: 11,
                            color: AppColors.grey_4,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      // 별점
                      const Icon(Icons.star, size: 13, color: Colors.amber),
                      const SizedBox(width: 2),
                      Text(
                        rating.toString(),
                        style: AppTextStyles.pretendard_bold.copyWith(
                          fontSize: 12,
                          color: AppColors.grey_6,
                        ),
                      ),

                      const SizedBox(width: 6),

                      // [추가] 좋아요 아이콘 및 수
                      Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        size: 13,
                        color: isLiked ? AppColors.main : AppColors.grey_4,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        likeCount.toString(),
                        style: AppTextStyles.pretendard_bold.copyWith(
                          fontSize: 12,
                          color: AppColors.grey_6,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // 식당 이름
                  Text(
                    placeName,
                    style: AppTextStyles.pretendard_bold.copyWith(
                      fontSize: 15,
                      color: AppColors.grey_6,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 12),

                  // 취향 일치도 배지
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.main.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '내 취향 $preference% 일치',
                      style: AppTextStyles.pretendard_bold.copyWith(
                        fontSize: 11,
                        color: AppColors.main,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StatisticsCard extends StatelessWidget {
  // ... (기존 코드 유지)
  final int activeStudents;
  final int reviewCount;
  final int restaurantCount;

  const StatisticsCard({
    super.key,
    required this.activeStudents,
    required this.reviewCount,
    required this.restaurantCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 22),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.grey_4.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildItem(
            icon: Icons.person_outline,
            label: '활동 학생',
            value: '${_formatNumber(activeStudents)}명',
          ),
          _buildDivider(),
          _buildItem(
            icon: Icons.chat_bubble_outline,
            label: '리뷰',
            value: '${_formatNumber(reviewCount)}개',
          ),
          _buildDivider(),
          _buildItem(
            icon: Icons.trending_up,
            label: '맛집',
            value: '${_formatNumber(restaurantCount)}곳',
          ),
        ],
      ),
    );
  }

  Widget _buildItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppColors.main,
          size: 28,
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: AppTextStyles.pretendard_medium.copyWith(
            color: AppColors.grey_5,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.pretendard_bold.copyWith(
            color: AppColors.main,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 32,
      width: 1,
      color: AppColors.grey_4.withOpacity(0.25),
    );
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (m) => '${m[1]},',
    );
  }
}