import 'package:campit_frontend/shared/constants/app_colors.dart';
import 'package:flutter/material.dart';
import '../../constants/tabs.dart'; // TabItem(icon, label)과 TABS 제공한다고 가정
import 'package:campit_frontend/shared/constants/app_assets.dart';
import 'package:campit_frontend/shared/constants/app_text_styles.dart';

//
// class BottomNavBar extends StatelessWidget {
//   const BottomNavBar({
//     super.key,
//     required this.currentIndex,
//     required this.onTap,
//     this.tabs = TABS,
//     this.backgroundColor,
//     this.activeColor,
//     this.inactiveColor,
//     this.elevation = 12,
//   });
//
//   final int currentIndex;                 // 현재 선택된 인덱스
//   final ValueChanged<int> onTap;          // 탭 눌렀을 때 콜백
//   final List<TabItem> tabs;               // 아이콘/라벨 데이터
//   final Color? backgroundColor;
//   final Color? activeColor;
//   final Color? inactiveColor;
//   final double elevation;
//
//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final active = activeColor ?? AppColors.activeColor;
//     final inactive = inactiveColor ?? AppColors.inactiveColor;
//
//     const baseHeight = kBottomNavigationBarHeight; // 56.0 (머티리얼 기본)
//
//     return Material(
//       elevation: elevation,
//       color: AppColors.plumu_white,
//       child: SafeArea(
//         top: false,
//         child: SizedBox(
//           height: baseHeight,
//           child: Row(
//             children: [
//               for (int i = 0; i < tabs.length; i++)
//                 _BottomItem(
//                   iconPath: tabs[i].icon,
//                   label: tabs[i].label,
//                   selected: i == currentIndex,
//                   activeColor: active,
//                   inactiveColor: inactive,
//                   onTap: () => onTap(i),
//                 ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class _BottomItem extends StatelessWidget {
//   const _BottomItem({
//     required this.iconPath,
//     required this.label,
//     required this.selected,
//     required this.activeColor,
//     required this.inactiveColor,
//     required this.onTap,
//   });
//
//   final String iconPath;
//   final String label;
//   final bool selected;
//   final Color activeColor;
//   final Color inactiveColor;
//   final VoidCallback onTap;
//
//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: InkWell(
//         onTap: onTap,
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 200),
//           padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
//           child: SizedBox(
//             height: 48,
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Image.asset(
//                   iconPath,
//                   width: 19, //이렇게 직접 지정할수도 있고, 주석처리해서 기본 이미지대로 할수도 있음.
//                   height: 19,
//                   color: selected ? activeColor : inactiveColor,
//                 ),
//                 const SizedBox(height: 3),
//                 SizedBox(
//                   child: Text(
//                     label,
//                     textAlign: TextAlign.center,
//                     style: TextStyle(
//                       color: selected ? activeColor : inactiveColor,
//                       fontSize: 9,
//                       fontFamily: 'Pretendard',
//                       fontWeight: FontWeight.w700,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

class BottomNavBar extends StatelessWidget {
  final String currentRoute;

  const BottomNavBar({
    super.key,
    required this.currentRoute,
  });

  static const String homeRoute = "/home";
  static const String mapRoute = "/map";
  static const String profileRoute = "/profile";

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border(
          top: BorderSide(
            color: AppColors.grey_4.withOpacity(0.2),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _BottomItem(
            label: '홈',
            iconPath: AppAssets.home_icon,
            isActive: currentRoute == homeRoute,
            onTap: () => _onTap(context, homeRoute),
          ),
          _BottomItem(
            label: '지도',
            iconPath: AppAssets.map_icon,
            isActive: currentRoute == mapRoute,
            onTap: () => _onTap(context, mapRoute),
          ),
          _BottomItem(
            label: '프로필',
            iconPath: AppAssets.profile_icon,
            isActive: currentRoute == profileRoute,
            onTap: () => _onTap(context, profileRoute),
          ),
        ],
      ),
    );
  }

  void _onTap(BuildContext context, String route) {
    if (route == currentRoute) return; // 이미 활성화된 화면이면 이동 X
    Navigator.pushNamed(context, route);
  }
}

class _BottomItem extends StatelessWidget {
  final String label;
  final bool isActive;
  final String iconPath;
  final VoidCallback onTap;

  const _BottomItem({
    required this.label,
    required this.isActive,
    required this.iconPath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.translucent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            iconPath,
            height: 28,
            color: isActive ? AppColors.main : AppColors.grey_4,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.pretendard_regular.copyWith(
              color: isActive ? AppColors.main : AppColors.grey_4,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
