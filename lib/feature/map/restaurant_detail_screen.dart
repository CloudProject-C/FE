import 'package:campit_frontend/feature/map/review_write_screen.dart';
import 'package:campit_frontend/shared/ui/buttons/primary_button.dart';
import 'package:campit_frontend/shared/ui/buttons/secondary_button.dart';
import 'package:campit_frontend/shared/ui/custom_dropdown_filter.dart';
import 'package:flutter/material.dart';
import 'package:campit_frontend/shared/constants/app_colors.dart';
import 'package:campit_frontend/shared/constants/app_text_styles.dart';
import 'package:location/location.dart';

class RestaurantDetailScreen extends StatefulWidget {
  const RestaurantDetailScreen({super.key});

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  String selectedSort = "AI 추천순";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _TopBar(),
              const SizedBox(height: 12),
              const _MatchCard(),
              const SizedBox(height: 20),
              const _TitleSection(),
              const SizedBox(height: 16),
              const _InfoSection(),
              const SizedBox(height: 30),
              const _ActionButtons(),
              const SizedBox(height: 32),
              _ReviewHeader(
                count: 3,
                selected: selectedSort,
                onSelected: (value) {
                  setState(() => selectedSort = value);
                },
              ),
              const SizedBox(height: 16),
              const _ReviewItem(),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.grey_4,
            size: 20,
          ),
        ),
      ],
    );
  }
}

class _MatchCard extends StatelessWidget {
  const _MatchCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // 등급 박스 (Asset 예정)
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.main,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "S",
                    style: AppTextStyles.pretendard_regular.copyWith(color: AppColors.white),
                  ),
                  Text(
                    "등급",
                    style: AppTextStyles.pretendard_regular.copyWith(color: AppColors.white),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 24),

          // 오른쪽 매칭 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "91%",
                      style: AppTextStyles.pretendard_regular.copyWith(
                        color: AppColors.main,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "매칭",
                      style: AppTextStyles.pretendard_regular.copyWith(color: AppColors.grey_4),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  "한식 선호도 기반",
                  style: AppTextStyles.pretendard_regular.copyWith(color: AppColors.grey_4),
                ),

                const SizedBox(height: 14),

                // 게이지(나중에 실제 이미지로 대체)
                SizedBox(
                  height: 40,
                  child: Placeholder(), // 네가 이미지로 교체
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _TitleSection extends StatelessWidget {
  const _TitleSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                "경희 떡볶이",
                style: AppTextStyles.pretendard_regular.copyWith(
                  color: AppColors.grey_4,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                "(3개 리뷰)",
                style: AppTextStyles.pretendard_regular.copyWith(color: AppColors.grey_4),
              ),
            ],
          ),
          Icon(
            Icons.share,
            size: 20,
            color: AppColors.grey_4,
          )
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("분식", style: AppTextStyles.pretendard_regular.copyWith(color: AppColors.grey_4)),
          const SizedBox(height: 8),

          Row(
            children: [
              Icon(Icons.favorite, color: AppColors.main, size: 20),
              const SizedBox(width: 6),
              Text("73", style: AppTextStyles.pretendard_regular.copyWith(color: AppColors.grey_4)),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Icon(Icons.location_on_outlined, color: AppColors.grey_4, size: 20),
              const SizedBox(width: 6),
              Text("서울 동대문구 경희대로 26 • 120m",
                  style: AppTextStyles.pretendard_regular.copyWith(color: AppColors.grey_4)),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Icon(Icons.phone, color: AppColors.grey_4, size: 20),
              const SizedBox(width: 6),
              Text("02-1234-5678",
                  style: AppTextStyles.pretendard_regular.copyWith(color: AppColors.grey_4)),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Icon(Icons.access_time, color: AppColors.grey_4, size: 20),
              const SizedBox(width: 6),
              Text("11:00 - 21:00",
                  style: AppTextStyles.pretendard_regular.copyWith(color: AppColors.grey_4)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons();

  @override
  Widget build(BuildContext context) {
    LocationData? myLocation;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: PrimaryButton(
              text: "리뷰 작성",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ReviewWriteScreen(),
                  ),
                );
              },
              height: 46,
              width: double.infinity,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: SecondaryButton(
                text: '길찾기',
                onTap: (){return null;},
                width: double.infinity,
                height: 46,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewHeader extends StatelessWidget {
  final int count;
  final String selected;
  final ValueChanged<String> onSelected;

  const _ReviewHeader({
    required this.count,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "리뷰 $count",
            style: AppTextStyles.pretendard_regular.copyWith(
              color: AppColors.grey_4,
              fontWeight: FontWeight.w600,
            ),
          ),
          CustomDropdownFilter(
            selected: selected,
            items: const ["최신순", "오래된순", "별점 높은순", "별점 낮은순", "좋아요순"],
            onSelected: onSelected,
          ),
        ],
      ),
    );
  }
}

class _ReviewItem extends StatelessWidget {
  const _ReviewItem();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFFFFA17A), Color(0xFFFD6E6A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              const SizedBox(width: 10),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("회기동주민",
                      style: AppTextStyles.pretendard_regular.copyWith(color: AppColors.grey_4)),
                  Text("1주 전",
                      style: AppTextStyles.pretendard_regular.copyWith(color: AppColors.grey_4))
                ],
              )
            ],
          ),

          const SizedBox(height: 12),

          Text(
            "오래된 맛집이에요. 사장님도 친절하시고 가성비 최고입니다.",
            style: AppTextStyles.pretendard_regular.copyWith(color: AppColors.grey_4),
          ),

          const SizedBox(height: 12),

          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppColors.grey_1,
            ),
            clipBehavior: Clip.hardEdge,
            child: Placeholder(), // 여기 사진 넣으면 됨
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Icon(Icons.favorite_border, size: 20, color: AppColors.grey_4),
              const SizedBox(width: 4),
              Text("8", style: AppTextStyles.pretendard_regular.copyWith(color: AppColors.grey_4)),
            ],
          ),
        ],
      ),
    );
  }
}

