import 'package:campit_frontend/feature/map/list.dart';
import 'package:campit_frontend/shared/constants/app_assets.dart';
import 'package:campit_frontend/shared/ui/custom_dropdown_filter.dart';
import 'package:flutter/material.dart';
import 'package:campit_frontend/shared/constants/app_colors.dart';
import 'package:campit_frontend/shared/constants/app_text_styles.dart';
import 'package:campit_frontend/shared/ui/bars/bottom_nav_bar.dart';
import 'package:campit_frontend/feature/map/map.dart';

class MapScreen extends StatefulWidget {
  static const routeName = "/map";

  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

enum MapTab { map, list }

class _MapScreenState extends State<MapScreen> {
  MapTab currentTab = MapTab.map;
  final PageController pageController = PageController();

  // 필터 영역
  String selectedSort = "추천순(유사도)";
  String selectedCategory = "한식";

  final Map<String, String> Kor_Eng_Dictionary = {
    "한식": "KOREAN",
    "양식": "WESTERN",
    "일식": "JAPANESE",
    "중식": "CHINESE",
    "카페": "CAFE",
    "디저트": "DESSERT",

    "거리순": "DISTANCE",
    "평점순": "LIKES",
    "리뷰 많은 순": "REVIEW",
    "추천순(유사도)": "RECOMMENDATION",
  };

  void _onTabSelected(MapTab tab) {
    setState(() => currentTab = tab);
    pageController.animateToPage(
      tab.index,
      duration: const Duration(milliseconds: 230),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.white,
        bottomNavigationBar: const BottomNavBar(
          currentRoute: MapScreen.routeName,
        ),
        body: SafeArea(
          child: Column(
            children: [
              Image.asset(
                AppAssets.logo_orange,
                width: 100,
              ),
              _buildHeader(),
      
              const SizedBox(height: 12),
      
              _buildFilterArea(),
      
              const SizedBox(height: 16),
      
              //상단 탭 영역 (지도 / 리스트)
              _buildMapTabBar(),

              const SizedBox(height: 10),
      
              //탭에 따른 페이지 전환
              Expanded(
                child: PageView(
                  controller: pageController,
                  physics: const NeverScrollableScrollPhysics(), // 스와이프 금지
                  onPageChanged: (index) {
                    setState(() {
                      currentTab = MapTab.values[index];
                    });
                  },
                  children: [
                    MapArea(category: Kor_Eng_Dictionary[selectedCategory]),
                    ListScreen(
                      category: Kor_Eng_Dictionary[selectedCategory],
                      sort: Kor_Eng_Dictionary[selectedSort] ?? "",
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 상단 (로고 + 검색창)
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 검색창
          Container(
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.grey_4.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                const Icon(Icons.search, size: 22, color: AppColors.grey_4),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    cursorColor: AppColors.grey_4,
                    style: AppTextStyles.pretendard_regular.copyWith(
                      color: AppColors.grey_4,
                      fontSize: 15,
                    ),
                    decoration: InputDecoration(
                      hintText: "음식점 또는 카테고리 검색",
                      hintStyle: AppTextStyles.pretendard_regular.copyWith(
                        color: AppColors.grey_4.withOpacity(0.5),
                      ),
                      border: InputBorder.none,
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

  Widget _buildFilterArea() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: CustomDropdownFilter(
              selected: selectedSort,
              items: const ["추천순(유사도)", "거리순", "리뷰 많은 순", "평점순"],
              onSelected: (value) {
                setState(() => selectedSort = value);
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: CustomDropdownFilter(
              selected: selectedCategory,
              items: const ["한식", "양식", "일식", "중식", "카페", "디저트"],
              onSelected: (value) {
                setState(() => selectedCategory = value);
              },
            ),
          ),
        ],
      ),
    );
  }

  // 상단 탭바 (지도 / 리스트)
  Widget _buildMapTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _MapTabButton(
              icon: Icons.map,
              tab: MapTab.map,
              label: "지도",
              isActive: currentTab == MapTab.map,
              onTap: () => _onTabSelected(MapTab.map),
            ),
          ),
          Expanded(
            child: _MapTabButton(
              icon: Icons.list,
              tab: MapTab.list,
              label: "리스트",
              isActive: currentTab == MapTab.list,
              onTap: () => _onTabSelected(MapTab.list),
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------------------
// 상단 탭 버튼 (지도 / 리스트)
// ------------------------------
class _MapTabButton extends StatelessWidget {
  final IconData icon;
  final MapTab tab;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _MapTabButton({
    required this.icon,
    required this.tab,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 22, color: isActive ? AppColors.main : AppColors.grey_4,), // 아이콘 자리
              const SizedBox(width: 3),
              Text(
                label,
                style: AppTextStyles.pretendard_regular.copyWith(
                  color: isActive ? AppColors.main : AppColors.grey_4,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Container(
            height: 2.5,
            width: 50,
            color: isActive ? AppColors.main : Colors.transparent,
          ),
        ],
      ),
    );
  }
}