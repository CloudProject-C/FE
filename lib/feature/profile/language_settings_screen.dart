import 'package:flutter/material.dart';
import 'package:campit_frontend/shared/constants/app_colors.dart';
import 'package:campit_frontend/shared/constants/app_text_styles.dart';

class LanguageSettingsScreen extends StatefulWidget {
  const LanguageSettingsScreen({super.key});

  @override
  State<LanguageSettingsScreen> createState() => _LanguageSettingsScreenState();
}

class _LanguageSettingsScreenState extends State<LanguageSettingsScreen> {
  final List<String> languages = const [
    '한국어',
    'English',
    '日本語',
    '中文(简体)',
    '中文(繁體)',
    'Español',
    'Français',
    'Deutsch',
    'Italiano',
    'Português',
    'Русский',
    'Türkçe',
    'العربية',
    'हिन्दी',
    'Bahasa Indonesia',
    'Bahasa Melayu',
    'ภาษาไทย',
    'Tiếng Việt',
  ];

  int selectedIndex = 0; // 기본: 한국어

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
          '언어 설정',
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
        child: ListView.separated(
          itemCount: languages.length,
          separatorBuilder: (_, __) => const Divider(
            height: 1,
            color: AppColors.grey_1,
          ),
          itemBuilder: (context, index) {
            final selected = index == selectedIndex;
            return InkWell(
              onTap: () {
                setState(() {
                  selectedIndex = index;
                });
              },
              child: Container(
                color: AppColors.white,
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        languages[index],
                        style: AppTextStyles.pretendard_regular.copyWith(
                          fontSize: 15,
                          color: selected
                              ? AppColors.main
                              : AppColors.grey_8,
                        ),
                      ),
                    ),
                    if (selected)
                      const Icon(
                        Icons.check,
                        size: 18,
                        color: AppColors.main,
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
