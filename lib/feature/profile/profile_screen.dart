import 'package:flutter/material.dart';
import 'package:campit_frontend/shared/constants/app_colors.dart';
import 'package:campit_frontend/shared/constants/app_text_styles.dart';
import 'package:campit_frontend/shared/ui/bars/bottom_nav_bar.dart';
import 'package:campit_frontend/feature/account/login_screen.dart';
//이후 shared로 다시 작업
import 'package:campit_frontend/feature/profile/settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  static const routeName = '/profile';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppColors.grey_1,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          centerTitle: false,
          titleSpacing: 24,
          title: Text(
            '프로필',
            style: AppTextStyles.pretendard_bold.copyWith(
              fontSize: 22,
              color: AppColors.grey_8,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(
              height: 1,
              color: AppColors.grey_2,
            ),
          ),
        ),
        body: const SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ProfileHeaderCard(),
                  SizedBox(height: 24),
                  _PreferenceSection(),
                  SizedBox(height: 24),
                  _SettingsSection(),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: const BottomNavBar(
          currentRoute: ProfileScreen.routeName,
        ),
      ),
    );
  }
}

/// 상단 프로필 카드 + 통계
class _ProfileHeaderCard extends StatelessWidget {
  const _ProfileHeaderCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 프로필 기본 정보
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.main_30per,
                ),
                child: const Icon(
                  Icons.person,
                  color: AppColors.main,
                  size: 36,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '캠퍼스 미식가',
                      style: AppTextStyles.pretendard_bold.copyWith(
                        fontSize: 18,
                        color: AppColors.grey_8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.mail_outline,
                          size: 14,
                          color: AppColors.grey_4,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'student@khu.ac.kr',
                          style: AppTextStyles.pretendard_regular.copyWith(
                            fontSize: 12,
                            color: AppColors.grey_5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: AppColors.grey_4,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '경희대학교',
                          style: AppTextStyles.pretendard_regular.copyWith(
                            fontSize: 12,
                            color: AppColors.grey_5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // 통계 카드 (작성한 리뷰 / 받은 좋아요)
          Row(
            children: const [
              Expanded(
                child: _StatCard(
                  label: '작성한 리뷰',
                  value: '12',
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  label: '받은 좋아요',
                  value: '45',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 피그마 스타일 통계 카드
class _StatCard extends StatelessWidget {
  final String label;
  final String value;

  const _StatCard({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        // TODO: 상세 화면 이동
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 88,
        decoration: BoxDecoration(
          color: AppColors.grey_1,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: AppTextStyles.pretendard_medium.copyWith(
                  fontSize: 13,
                  color: AppColors.grey_6,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: AppTextStyles.pretendard_bold.copyWith(
                  fontSize: 16,
                  color: AppColors.main,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 선호 음식 영역
class _PreferenceSection extends StatelessWidget {
  const _PreferenceSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '선호 음식',
            style: AppTextStyles.pretendard_bold.copyWith(
              fontSize: 16,
              color: AppColors.grey_8,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: const [
              _PreferenceTile(),
            ],
          ),
        ],
      ),
    );
  }
}

/// 선호 음식 카드 (예시로 '중식')
class _PreferenceTile extends StatelessWidget {
  const _PreferenceTile();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 84,
      height: 96,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.main,
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // TODO: 나중에 이미지 에셋으로 교체
          // 임시 이모지
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.grey_1,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text(
                '🍜',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '중식',
            style: AppTextStyles.pretendard_medium.copyWith(
              fontSize: 13,
              color: AppColors.main,
            ),
          ),
        ],
      ),
    );
  }
}

/// 설정 / 로그아웃 영역
class _SettingsSection extends StatelessWidget {
  const _SettingsSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _SettingsItem(
            icon: Icons.settings_outlined,
            label: '설정',
            isDestructive: false,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const SettingsScreen(),
                ),
              );
            },
          ),
          const Divider(
            height: 1,
            color: AppColors.grey_1,
          ),
          _SettingsItem(
            icon: Icons.logout_rounded,
            label: '로그아웃',
            isDestructive: true,
            onTap: () {
              _showLogoutDialog(context);
            },
          ),
        ],
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDestructive;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final textStyle = isDestructive
        ? AppTextStyles.pretendard_medium.copyWith(
      fontSize: 14,
      color: Colors.red,
    )
        : AppTextStyles.pretendard_medium.copyWith(
      fontSize: 14,
      color: AppColors.grey_7,
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isDestructive ? Colors.red : AppColors.grey_6,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: textStyle,
              ),
            ),
            if (!isDestructive)
              const Icon(
                Icons.chevron_right,
                size: 18,
                color: AppColors.grey_4,
              ),
          ],
        ),
      ),
    );
  }
}

/// 로그아웃 확인 팝업
Future<void> _showLogoutDialog(BuildContext context) async {
  final shouldLogout = await showDialog<bool>(
    context: context,
    barrierDismissible: true,
    builder: (dialogContext) {
      return Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '로그아웃',
                  style: AppTextStyles.pretendard_bold.copyWith(
                    fontSize: 16,
                    color: AppColors.grey_8,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '데이터는 계정에 남아 있으며\n로그인하면 다시 사용할 수 있습니다.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.pretendard_regular.copyWith(
                    fontSize: 13,
                    height: 1.4,
                    color: AppColors.grey_5,
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop(false);
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: AppColors.grey_3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                          padding:
                          const EdgeInsets.symmetric(vertical: 11),
                        ),
                        child: Text(
                          '취소',
                          style: AppTextStyles.pretendard_medium.copyWith(
                            fontSize: 14,
                            color: AppColors.grey_7,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop(true);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.main,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                          padding:
                          const EdgeInsets.symmetric(vertical: 11),
                        ),
                        child: Text(
                          '로그아웃',
                          style: AppTextStyles.pretendard_bold.copyWith(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );

  if (shouldLogout == true) {
    // 실제 로그아웃 처리 필요 시 여기에서 수행

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
          (route) => false,
    );
  }
}
