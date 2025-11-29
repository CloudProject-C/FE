import 'package:campit_frontend/feature/home/home_screen.dart';
import 'package:campit_frontend/shared/constants/app_assets.dart';
import 'package:flutter/material.dart';

class TabItem {
  final String icon;
  final String label;
  final Widget page;

  const TabItem({
    required this.icon,
    required this.label,
    required this.page,
  });
}

const TABS = [
  TabItem(icon: AppAssets.home_icon, label: '홈', page: HomeScreen()),
  //TabItem(icon: AppAssets.puzzle, label: '퍼즐', page: PuzzleRoot()),
  //TabItem(icon: AppAssets.mypage, label: '마이페이지', page: ProfileRoot())
];
