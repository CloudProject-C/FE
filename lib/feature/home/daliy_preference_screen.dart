import 'package:campit_frontend/services/storage_service.dart';
import 'package:campit_frontend/shared/constants/app_assets.dart';
import 'package:campit_frontend/shared/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:campit_frontend/shared/constants/app_colors.dart';
import 'package:campit_frontend/shared/constants/app_text_styles.dart';
import 'package:campit_frontend/feature/home/home_screen.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DaliyFoodPreferenceScreen extends StatefulWidget {
  const DaliyFoodPreferenceScreen({super.key});

  @override
  State<DaliyFoodPreferenceScreen> createState() => _DaliyFoodPreferenceScreenState();
}

class _DaliyFoodPreferenceScreenState extends State<DaliyFoodPreferenceScreen> {
  final List<String> items = [
    "고기/고단백",     // meat_protein
    "해산물",          // seafood
    "국물/찌개류",      // soup_stew
    "면 요리",         // noodle
    "밥 요리",         // rice
    "분식",            // street_food
    "디저트/카페",      // dessert_cafe
    "간편식/빠른",      // quick
    "건강식",          // healthy
  ];

  final Map<String, String> Kor_Eng_Dictionary = {
    "매움": "spicy",
    "한식": "korean",
    "양식": "western",
    "중식": "chinese",
    "일식": "japanese",
    "아시안": "asian",
    "분위기": "mood",
    "건강식": "healthy",
    "고칼로리/단백질": "protain",
  };

  final Set<String> selected = {};

  Future<void> _sendPreference() async {
    // 1. 선택된 취향이 없으면 아무것도 하지 않음
    if (selected.isEmpty) {
      print("선택된 취향이 없습니다.");
      return;
    }

    final _accessToken = await StorageService.getAccessToken();

    final url = Uri.parse('$baseUrl/v1/preference/recommend');

    try {

      print("selected list is: ${selected.toList()}");
      print(jsonEncode({
        "features": selected.toList(), // Set을 List로 변환하여 전송
      }));
      // 2. 서버 요청 (POST)
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_accessToken',
        },
        body: jsonEncode({
          "features": selected.toList(), // Set을 List로 변환하여 전송
        }),
      );

      // 3. 응답 처리
      if (response.statusCode == 200 || response.statusCode == 201) {
        print("취향 전송 성공: ${response.body}");

        if (!mounted) return;

        // 성공 시 다음 화면(메인 등)으로 이동
        Navigator.pushNamed(
          context,
          '/home',
        );
      } else {
        print("취향 전송 실패: ${response.statusCode} - ${response.body}");
        // 필요하다면 에러 스낵바 표시
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('전송 실패: ${response.statusCode}')),
        );
      }
    } catch (e) {
      print("네트워크 오류 발생: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('네트워크 오류가 발생했습니다.')),
      );
    }
  }

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
                                  AppAssets.map_icon,
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
                    _sendPreference();
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
