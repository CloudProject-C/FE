import 'package:flutter/material.dart';
import 'package:campit_frontend/shared/constants/app_colors.dart';
import 'package:campit_frontend/shared/constants/app_text_styles.dart';
import 'package:campit_frontend/feature/profile/profile_edit_screen.dart';
import 'package:campit_frontend/feature/profile/password_change_screen.dart';
import 'package:campit_frontend/feature/profile/language_settings_screen.dart';
import 'package:campit_frontend/feature/profile/notification_settings_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey_1,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 18,
            color: AppColors.grey_7,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '설정',
          style: AppTextStyles.pretendard_bold.copyWith(
            fontSize: 18,
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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SettingsSectionGroup(
                  title: '계정',
                  items: [
                    SettingsItemData(
                      icon: Icons.person_outline,
                      label: '프로필 편집',
                      onTap: (ctx) {
                        Navigator.of(ctx).push(
                          MaterialPageRoute(
                            builder: (_) => const ProfileEditScreen(),
                          ),
                        );
                      },
                    ),
                    SettingsItemData(
                      icon: Icons.lock_outline,
                      label: '비밀번호 변경',
                      onTap: (ctx) {
                        Navigator.of(ctx).push(
                          MaterialPageRoute(
                            builder: (_) => const PasswordChangeScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _SettingsSectionGroup(
                  title: '앱 설정',
                  items: [
                    SettingsItemData(
                      icon: Icons.notifications_none_rounded,
                      label: '알림 설정',
                      onTap: (ctx) {
                        Navigator.of(ctx).push(
                          MaterialPageRoute(
                            builder: (_) =>
                            const NotificationSettingsScreen(),
                          ),
                        );
                      },
                    ),
                    SettingsItemData(
                      icon: Icons.language_rounded,
                      label: '언어 설정',
                      onTap: (ctx) {
                        Navigator.of(ctx).push(
                          MaterialPageRoute(
                            builder: (_) => const LanguageSettingsScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _SettingsSectionGroup(
                  title: '기타',
                  items: [
                    SettingsItemData(
                      icon: Icons.description_outlined,
                      label: '이용약관',
                      onTap: (ctx) {
                        // 필요시 다시 작업
                      },
                    ),
                    SettingsItemData(
                      icon: Icons.shield_outlined,
                      label: '개인정보 처리방침',
                      onTap: (ctx) {
                        // 필요시 다시 작업
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                Center(
                  child: Text(
                    '버전 1.0.0',
                    style: AppTextStyles.pretendard_regular.copyWith(
                      fontSize: 12,
                      color: AppColors.grey_4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SettingsItemData {
  final IconData icon;
  final String label;
  final void Function(BuildContext context) onTap;

  SettingsItemData({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}

class _SettingsSectionGroup extends StatelessWidget {
  final String title;
  final List<SettingsItemData> items;

  const _SettingsSectionGroup({
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.pretendard_medium.copyWith(
            fontSize: 13,
            color: AppColors.grey_4,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              for (int i = 0; i < items.length; i++) ...[
                _SettingsRow(item: items[i]),
                if (i != items.length - 1)
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.grey_1,
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final SettingsItemData item;

  const _SettingsRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => item.onTap(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Row(
          children: [
            Icon(
              item.icon,
              size: 22,
              color: AppColors.grey_7,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                item.label,
                style: AppTextStyles.pretendard_regular.copyWith(
                  fontSize: 15,
                  color: AppColors.grey_8,
                ),
              ),
            ),
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
