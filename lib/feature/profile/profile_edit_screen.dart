import 'package:flutter/material.dart';
import 'package:campit_frontend/shared/constants/app_colors.dart';
import 'package:campit_frontend/shared/constants/app_text_styles.dart';
import 'package:campit_frontend/shared/ui/buttons/primary_button.dart';

class ProfileEditScreen extends StatefulWidget {
  final String initialNickname;

  const ProfileEditScreen({
    super.key,
    required this.initialNickname,
  });

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  late TextEditingController nicknameController;
  late TextEditingController emailController;
  late TextEditingController schoolController;

  @override
  void initState() {
    super.initState();
    nicknameController =
        TextEditingController(text: widget.initialNickname);
    emailController = TextEditingController(text: 'student@khu.ac.kr');
    schoolController = TextEditingController(text: '경희대학교');
  }

  @override
  void dispose() {
    nicknameController.dispose();
    emailController.dispose();
    schoolController.dispose();
    super.dispose();
  }

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
          '프로필 편집',
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
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        child: PrimaryButton(
          width: double.infinity,
          height: 54,
          text: '저장',
          height: 52,
          width: double.infinity,
          onTap: () {
            Navigator.of(context).pop(nicknameController.text.trim());
          },
        ),
      ),
      body: SafeArea(
        child: GestureDetector(
          // 빈 곳 탭하면 키보드 내려가도록
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.translucent,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 80),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 프로필 이미지 + 사진 변경
                  Column(
                    children: [
                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.main_30per,
                            ),
                            child: const Icon(
                              Icons.person,
                              size: 50,
                              color: AppColors.main,
                            ),
                          ),
                          Positioned(
                            right: 6,
                            bottom: 6,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: const BoxDecoration(
                                color: AppColors.main,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt_outlined,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '사진 변경',
                        style: AppTextStyles.pretendard_medium.copyWith(
                          fontSize: 13,
                          color: AppColors.main,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: AppColors.grey_1,
                  ),
                  const SizedBox(height: 24),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _LabeledField(
                          label: '닉네임',
                          controller: nicknameController,
                          readOnly: false,
                          backgroundColor: Colors.white,
                        ),
                        const SizedBox(height: 16),
                        _LabeledField(
                          label: '이메일',
                          controller: emailController,
                          readOnly: true,
                          backgroundColor: AppColors.grey_1,
                        ),
                        const SizedBox(height: 16),
                        _LabeledField(
                          label: '학교',
                          controller: schoolController,
                          readOnly: true,
                          backgroundColor: AppColors.grey_1,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool readOnly;
  final Color backgroundColor;

  const _LabeledField({
    required this.label,
    required this.controller,
    this.readOnly = false,
    this.backgroundColor = AppColors.grey_1,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = readOnly ? AppColors.grey_4 : AppColors.grey_8;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.pretendard_regular.copyWith(
            fontSize: 13,
            color: AppColors.grey_5,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: backgroundColor == Colors.white
                  ? AppColors.grey_2
                  : Colors.transparent,
              width: 1,
            ),
          ),
          child: TextField(
            controller: controller,
            readOnly: readOnly,
            cursorColor: AppColors.main,
            style: AppTextStyles.pretendard_regular.copyWith(
              fontSize: 14,
              color: textColor,
            ),
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding:
              EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
          ),
        ),
      ],
    );
  }
}
