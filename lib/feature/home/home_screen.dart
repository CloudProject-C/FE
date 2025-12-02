import 'package:campit_frontend/shared/constants/app_assets.dart';
import 'package:flutter/material.dart';
import 'package:campit_frontend/shared/constants/app_colors.dart';
import 'package:campit_frontend/shared/constants/app_text_styles.dart';
import 'package:campit_frontend/shared/ui/bars/bottom_nav_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  static const routeName = "/home";

  @override
  Widget build(BuildContext context) {
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
                        const SizedBox(width: 80),
                        Text(
                          '경희대학교',
                          style: AppTextStyles.pretendard_regular.copyWith(
                            color: AppColors.white,
                            fontSize: 18,
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
}