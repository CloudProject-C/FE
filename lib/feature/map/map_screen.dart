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
    return Scaffold(
      backgroundColor: AppColors.white,
      bottomNavigationBar: const BottomNavBar(
        currentRoute: MapScreen.routeName,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),

            // ⬆ 상단 로고 & 검색창 (UI만 구성, 로직 없음)
            _buildHeader(),

            const SizedBox(height: 12),

            // ⬆ 필터 영역 (코드만 만들고 기능은 X)
            _buildFilterArea(),

            const SizedBox(height: 16),

            // ================================
            //      상단 탭 영역 (지도 / 리스트)
            // ================================
            _buildMapTabBar(),

            const SizedBox(height: 10),

            // ================================
            //       탭에 따른 페이지 전환
            // ================================
            Expanded(
              child: PageView(
                controller: pageController,
                physics: const NeverScrollableScrollPhysics(), // 스와이프 금지
                onPageChanged: (index) {
                  setState(() {
                    currentTab = MapTab.values[index];
                  });
                },
                children: const [
                  Map(),
                  MapListPage(),
                ],
              ),
            ),
          ],
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
          SizedBox(height: 36, child: Placeholder()), // 로고 자리

          const SizedBox(height: 14),

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
                const SizedBox(width: 22, height: 22, child: Placeholder()),
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

  // 필터 영역
  String selectedSort = "AI 추천순";
  String selectedCategory = "전체";

  Widget _buildFilterArea() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: CustomDropdownFilter(
              selected: selectedSort,
              items: const ["최신순", "좋아요순", "AI 추천순"],
              onSelected: (value) {
                setState(() => selectedSort = value);
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: CustomDropdownFilter(
              selected: selectedCategory,
              items: const ["전체", "한식", "양식", "분식"],
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
              tab: MapTab.map,
              label: "지도",
              isActive: currentTab == MapTab.map,
              onTap: () => _onTabSelected(MapTab.map),
            ),
          ),
          Expanded(
            child: _MapTabButton(
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
// 필터 Chip
// ------------------------------
// class _FilterChip extends StatelessWidget {
//   final String label;
//
//   const _FilterChip({required this.label});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 40,
//       decoration: BoxDecoration(
//         color: AppColors.grey_4.withOpacity(0.12),
//         borderRadius: BorderRadius.circular(10),
//       ),
//       alignment: Alignment.center,
//       child: Text(
//         label,
//         style: AppTextStyles.pretendard_regular.copyWith(
//           color: AppColors.grey_4,
//           fontSize: 14,
//         ),
//       ),
//     );
//   }
// }

// ------------------------------
// 상단 탭 버튼 (지도 / 리스트)
// ------------------------------
class _MapTabButton extends StatelessWidget {
  final MapTab tab;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _MapTabButton({
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
          SizedBox(width: 30, height: 30, child: Placeholder()), // 아이콘 자리
          const SizedBox(height: 6),
          Text(
            label,
            style: AppTextStyles.pretendard_regular.copyWith(
              color: isActive ? AppColors.main : AppColors.grey_4,
              fontSize: 15,
            ),
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

// ------------------------------
// 탭: 지도 페이지
// ------------------------------
// class Map extends StatelessWidget {
//   const Map({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: AppColors.white,
//       child: const Center(
//         child: Text("지도 화면 Placeholder"),
//       ),
//     );
//   }
// }

// ------------------------------
// 탭: 리스트 페이지
// ------------------------------
class MapListPage extends StatelessWidget {
  const MapListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      child: const Center(
        child: Text("리스트 화면 Placeholder"),
      ),
    );
  }
}
