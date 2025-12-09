import 'package:campit_frontend/shared/constants/app_assets.dart';
import 'package:flutter/material.dart';
import 'package:campit_frontend/shared/constants/app_colors.dart';
import 'package:campit_frontend/shared/constants/app_text_styles.dart';
import 'package:campit_frontend/feature/home/home_screen.dart';

class DaliyFoodPreferenceScreen extends StatefulWidget {
  const DaliyFoodPreferenceScreen({super.key});

  @override
  State<DaliyFoodPreferenceScreen> createState() => _DaliyFoodPreferenceScreenState();
}

class _DaliyFoodPreferenceScreenState extends State<DaliyFoodPreferenceScreen> {
  final List<String> items = [
    "면",
    "밥",
    "빵",
    "치킨",
    "피자",
    "떡볶이",
    "햄버거",
    "초밥",
    "디저트",
    "한식",
    "중식",
    "일식",
  ];

  final Set<String> selected = {};

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 40),

                // 로고
                Column(
                  children: [
                    Image.asset(
                      AppAssets.logo_orange,
                      height: 110,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '오늘 땡기는 음식을 선택하고 식당을\n추천받아보세요!',
                      style: AppTextStyles.pretendard_bold.copyWith(
                        color: AppColors.main,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '가입 시 조사한 선호도와 함께 가중치를\n매겨 식당별 선호도 매칭률 %를 계산합니다.\n(매 로그인 시 진행)',
                      style: AppTextStyles.pretendard_medium.copyWith(
                        color: AppColors.grey_4,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // 음식 아이템 그리드
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 3,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 18,
                    childAspectRatio: 0.95,
                    children: items.map((e) {
                      final isSelected = selected.contains(e);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              selected.remove(e);
                            } else {
                              selected.add(e);
                            }
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.main
                                  : AppColors.grey_4.withOpacity(0.3),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                blurRadius: 6,
                                color: Colors.black.withOpacity(0.05),
                                offset: const Offset(0, 2),
                              )
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // 음식 아이콘
                              SizedBox(
                                height: 40,
                                child: Image.asset(
                                  'assets/foods/$e.png',
                                  fit: BoxFit.contain,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                e,
                                style: AppTextStyles.pretendard_regular.copyWith(
                                  color: AppColors.grey_4,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 16),

                // 하단 안내 텍스트
                TextButton(
                  // 수정된 부분: if-else 대신 삼항 연산자 사용
                  onPressed: selected.isEmpty
                      ? null // 선택된 게 없으면 null (버튼 비활성화)
                      : () { // 선택된 게 있으면 함수 실행
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const HomeScreen(),
                      ),
                    );
                  },
                  child: Container(
                    height: 52,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.main.withOpacity(
                        selected.isEmpty ? 0.3 : 1,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      selected.isEmpty
                          ? "최소 1개 이상 선택하세요"
                          : "선택 완료",
                      style: AppTextStyles.pretendard_regular.copyWith(
                        color: AppColors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
