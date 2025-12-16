import 'package:campit_frontend/feature/account/onboard_preference_screen.dart';
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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
        future: HomeService.fetch_home_data(),
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            debugPrint("Snapshot Error: ${snapshot.error}");
            return Center(child: Text('에러 발생: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('데이터를 불러오지 못했습니다.'));
          }

          final result = snapshot.data!['result'];
          final schoolName = result['schoolName'];
          final schoolUserCount = result['schoolUserCount'];
          final schoolReviewCount = result['schoolReviewCount'];
          final schoolPlaceCount = result['schoolPlaceCount'];

          // [추가] 추천 식당 리스트 파싱
          final List<dynamic> recommendedPlaces = result['recommendedPlaces'] ?? [];

          return GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Scaffold(
              backgroundColor: AppColors.white,
              body: SafeArea(
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

                    // 스크롤 가능한 영역으로 감싸기 (화면 오버플로우 방지)
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),

                            StatisticsCard(
                                activeStudents: schoolUserCount,
                                reviewCount: schoolReviewCount,
                                restaurantCount: schoolPlaceCount
                            ),

                            const SizedBox(height: 30),

                            // [추가] 추천 식당 섹션
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

                            // 추천 식당 리스트 (가로 스크롤)
                            SizedBox(
                              height: 240, // 카드 높이 지정
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
                                            style: AppTextStyles.pretendard_regular.copyWith(
                                              color: AppColors.grey_4,
                                              fontSize: 18,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            '우리 학교 학생들만의 맛집 공유 플랫폼! 500m 인증을 통해 진짜 후기만 모아요. 내 취향에 맞는 맛집을 AI가 추천해드려요.',
                                            style: AppTextStyles.pretendard_regular.copyWith(
                                              color: AppColors.grey_4,
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
                      ),
                    ),
                  ],
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

// [추가] 추천 식당 카드 위젯
class _RecommendedPlaceCard extends StatelessWidget {
  final Map<String, dynamic> place;

  const _RecommendedPlaceCard({required this.place});

  @override
  Widget build(BuildContext context) {
    final imageUrl = place['recentImageUrl'];
    final placeName = place['placeName'] ?? '이름 없음';
    final category = place['categoryName'] ?? '기타';
    final rating = place['averageRating'] ?? 0.0;
    final preference = place['preferencePercent'] ?? 0;

    return Container(
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
                // 카테고리 & 별점
                Row(
                  children: [
                    Text(
                      category,
                      style: AppTextStyles.pretendard_regular.copyWith(
                        fontSize: 11,
                        color: AppColors.grey_4,
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.star, size: 14, color: Colors.amber),
                    const SizedBox(width: 2),
                    Text(
                      rating.toString(),
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
          size: 22,
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: AppTextStyles.pretendard_regular.copyWith(
            color: AppColors.grey_4,
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTextStyles.pretendard_regular.copyWith(
            color: AppColors.main,
            fontSize: 15,
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