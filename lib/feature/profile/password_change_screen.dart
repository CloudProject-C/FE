import 'package:flutter/material.dart';
import 'package:campit_frontend/shared/constants/app_colors.dart';
import 'package:campit_frontend/shared/constants/app_text_styles.dart';
import 'package:campit_frontend/shared/ui/buttons/primary_button.dart';

//TODO: 비밀번호 확인 기능 추가

class PasswordChangeScreen extends StatefulWidget {
  const PasswordChangeScreen({super.key});

  @override
  State<PasswordChangeScreen> createState() => _PasswordChangeScreenState();
}

class _PasswordChangeScreenState extends State<PasswordChangeScreen> {
  final currentController = TextEditingController();
  final newController = TextEditingController();
  final confirmController = TextEditingController();

  bool obscureCurrent = true;
  bool obscureNew = true;
  bool obscureConfirm = true;

  @override
  void dispose() {
    currentController.dispose();
    newController.dispose();
    confirmController.dispose();
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
          '비밀번호 변경',
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
          text: '변경하기',
          onTap: () {
            // TODO: 비밀번호 변경 로직
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.translucent,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 80),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PasswordLabeledField(
                    label: '현재 비밀번호',
                    controller: currentController,
                    hintText: '현재 비밀번호를 입력하세요',
                    obscure: obscureCurrent,
                    onToggle: () =>
                        setState(() => obscureCurrent = !obscureCurrent),
                  ),
                  const SizedBox(height: 20),
                  _PasswordLabeledField(
                    label: '새 비밀번호',
                    controller: newController,
                    hintText: '8자 이상 입력하세요',
                    obscure: obscureNew,
                    onToggle: () =>
                        setState(() => obscureNew = !obscureNew),
                  ),
                  const SizedBox(height: 20),
                  _PasswordLabeledField(
                    label: '새 비밀번호 확인',
                    controller: confirmController,
                    hintText: '비밀번호를 다시 입력하세요',
                    obscure: obscureConfirm,
                    onToggle: () =>
                        setState(() => obscureConfirm = !obscureConfirm),
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

/// 라벨 + 비밀번호 입력 필드 한 세트
class _PasswordLabeledField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hintText;
  final bool obscure;
  final VoidCallback onToggle;

  const _PasswordLabeledField({
    required this.label,
    required this.controller,
    required this.hintText,
    required this.obscure,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
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
        const SizedBox(height: 8),
        _PasswordField(
          controller: controller,
          hintText: hintText,
          obscure: obscure,
          onToggle: onToggle,
        ),
      ],
    );
  }
}

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscure;
  final VoidCallback onToggle;

  const _PasswordField({
    required this.controller,
    required this.hintText,
    required this.obscure,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.grey_1,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        cursorColor: AppColors.main,
        style: AppTextStyles.pretendard_regular.copyWith(
          fontSize: 14,
          color: AppColors.grey_8,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          hintText: hintText,
          hintStyle: AppTextStyles.pretendard_regular.copyWith(
            fontSize: 14,
            color: AppColors.grey_3,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              obscure ? Icons.visibility_off : Icons.visibility,
              color: AppColors.grey_4,
              size: 20,
            ),
            onPressed: onToggle,
          ),
        ),
      ),
    );
  }
}
