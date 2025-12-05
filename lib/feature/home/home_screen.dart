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

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('데이터를 불러오지 못했습니다.'));
          }

          final schoolName = snapshot.data!['result']['schoolName'];
          final schoolUserCount = snapshot.data!['result']['schoolUserCount'];
          final schoolReviewCount = snapshot.data!['result']['schoolReviewCount'];
          final schoolPlaceCount = snapshot.data!['result']['schoolPlaceCount'];

          return GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Scaffold(
              backgroundColor: AppColors.white,
              body: SafeArea(
                child: Column(
                  children: [
                    // 상단 영역 (로고 + 학교명 + 검색창)
                    Container(
                      width: double.infinity,
                      color: AppColors.main,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 로고 + 학교명
                          Row(
                            children: [
                              Image.asset(
                                AppAssets.logo_white,
                                height: 42,
                              ),
                              const SizedBox(width: 12),
                              // Image.asset(
                              //   'assets/logo/school_icon.png', // 학교 아이콘
                              //   height: 32,
                              // ),
                              const SizedBox(width: 50),
                              Text(
                                schoolName,
                                style: AppTextStyles.pretendard_bold.copyWith(
                                  color: AppColors.white,
                                  fontSize: 17,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // 검색창
                          Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: Row(
                              children: [
                                // Image.asset(
                                //   'assets/icons/search.png',
                                //   height: 20,
                                // ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    cursorColor: AppColors.grey_4,
                                    style: AppTextStyles.pretendard_regular.copyWith(
                                      color: AppColors.grey_4,
                                      fontSize: 15,
                                    ),
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: '맛집을 검색해보세요',
                                      hintStyle:
                                      AppTextStyles.pretendard_regular.copyWith(
                                        color: AppColors.grey_4.withOpacity(0.5),
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    StatisticsCard(
                        activeStudents: schoolUserCount,
                        reviewCount: schoolReviewCount,
                        restaurantCount: schoolPlaceCount
                    ),

                    const SizedBox(height: 20,),

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
                            // Image.asset(
                            //   'assets/icons/info.png', // 설명 아이콘
                            //   height: 32,
                            // ),
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

                    const SizedBox(height: 12),

                    // 화면 나머지 공간
                    Expanded(
                      child: Container(
                        color: AppColors.white,
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

class StatisticsCard extends StatelessWidget {
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