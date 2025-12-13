import 'package:campit_frontend/shared/constants/app_assets.dart';
import 'package:flutter/material.dart';
import 'package:campit_frontend/shared/constants/app_colors.dart';
import 'package:campit_frontend/shared/constants/app_text_styles.dart';
import 'package:campit_frontend/feature/home/daliy_preference_screen.dart';

class OnboardFoodPreferenceScreen extends StatefulWidget {
  final nickname;
  const OnboardFoodPreferenceScreen({
    super.key,
    required this.nickname,
  });

  @override
  State<OnboardFoodPreferenceScreen> createState() => _OnboardFoodPreferenceScreenState();
}

class _OnboardFoodPreferenceScreenState extends State<OnboardFoodPreferenceScreen> {
  final List<String> items = [
    "spicy",
    "한식",
    "양식",
    "중식",
    "일식",
    "아시안",
    "분위기",
    "건강식(저칼로리)",
    "고칼로리/단백질",
  ];

  final Map<String, String> Eng_Kor_Dictionary = {
    "spicy" : "매움",
    "korean" : "한식",
    "western" : "양식",
    "chinese" : "중식",
    "japanese" : "일식",
    "asian" : "아시안",
    "mood" : "분위기",
    "healthy" : "건강식(저칼로리)",
    "protain" : "고칼로리/단백질",
  };

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
                      '${widget.nickname}님의 음식 취향은 무엇인가요?',
                      style: AppTextStyles.pretendard_bold.copyWith(
                        color: AppColors.main,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'CampEat은 ${widget.nickname}님의 전반적인 음식 취향을\n분석해서 식당별 선호도 매칭률 %를 계산\n합니다. (온보딩 시 1회)',
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
                                  AppAssets.map_icon,
                                  fit: BoxFit.contain,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                Eng_Kor_Dictionary[e] ?? '',
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
                        builder: (_) => const DaliyFoodPreferenceScreen(),
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


