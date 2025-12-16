import 'package:campit_frontend/shared/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:campit_frontend/shared/constants/app_colors.dart';
import 'package:campit_frontend/shared/constants/app_text_styles.dart';
import 'package:campit_frontend/feature/account/sign_up_step2.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SignUpStep1Screen extends StatefulWidget {
  const SignUpStep1Screen({super.key});

  @override
  State<SignUpStep1Screen> createState() => _SignUpStep1ScreenState();
}

class _SignUpStep1ScreenState extends State<SignUpStep1Screen> {
  final emailController = TextEditingController();
  final codeController = TextEditingController();
  String? selectedSchool;

  bool get isFormValid =>
      (selectedSchool != null && selectedSchool!.isNotEmpty) &&
          emailController.text.isNotEmpty &&
          codeController.text.isNotEmpty;

  void sendEmail() async {
    try {
      final email = emailController.text.trim();

      final verifyEmailUri = Uri.parse('$baseUrl/email/send-email')
          .replace(queryParameters: {
        'email': email,
      });

      final response = await http.post(
        verifyEmailUri,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final verifyEmailResponse = jsonDecode(response.body);

        final code = verifyEmailResponse['code'].toString();

        debugPrint('----- response is: $verifyEmailResponse -----');
      } else {
        final decodedError = jsonDecode(response.body);
        debugPrint(decodedError.toString());

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('인증 중 서버에서 오류가 발생했습니다.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('이메일 인증 중 클라이언트에서 오류가 발생했습니다: $e'),
          duration: const Duration(seconds: 2),
        ),
      );

      debugPrint('Send-Email Error: $e');
    }
  }

  void verifyCode() async {
    try{
      final _email = emailController.text.trim();
      final _code = codeController.text.trim();
      final verifyCodeUri = Uri.parse('$baseUrl/email/verify');
      final response = await http.post(
          verifyCodeUri,
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'email': _email,
            'code': _code
          })
      );

      if (response.statusCode == 200) {
        final verifyCodeResponse = jsonDecode(response.body);
        debugPrint('----- response is: $verifyCodeResponse-----');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SignUpStep2Screen(
              email: _email,
              schoolId: 1,
            ),
          ),
        );
      } else {
        debugPrint(jsonDecode(response.body).toString());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('코드 인증 중 서버에서 오류가 발생했습니다.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('코드 인증 중 클라이언트에서 오류가 발생했습니다: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
      debugPrint('Code Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: AppColors.white,
        appBar: AppBar(
          backgroundColor: AppColors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.grey_5),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            '회원가입',
            style: AppTextStyles.pretendard_regular.copyWith(
              color: AppColors.grey_5,
              fontSize: 18,
            ),
          ),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),

                        _StepIndicator(current: 1),

                        const SizedBox(height: 40),
                        Text(
                          '학교 이메일 인증',
                          style: AppTextStyles.pretendard_regular.copyWith(
                            color: AppColors.grey_5,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '학교 이메일 인증이 필요합니다',
                          style: AppTextStyles.pretendard_regular.copyWith(
                            color: AppColors.grey_5,
                            fontSize: 14,
                          ),
                        ),

                        const SizedBox(height: 30),
                        Text(
                          '학교 선택',
                          style: AppTextStyles.pretendard_regular.copyWith(
                            color: AppColors.grey_5,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 6),

                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: AppColors.grey_5.withOpacity(0.2)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              hint: Text(
                                '학교를 선택하세요',
                                style: AppTextStyles.pretendard_regular
                                    .copyWith(color: AppColors.grey_5),
                              ),
                              value: selectedSchool,
                              items: const [
                                DropdownMenuItem(
                                    value: "경희대학교", child: Text("경희대학교")),
                                DropdownMenuItem(
                                    value: "서울대학교", child: Text("서울대학교")),
                                DropdownMenuItem(
                                    value: "연세대학교", child: Text("연세대학교")),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  selectedSchool = value;
                                });
                              },
                              style: AppTextStyles.pretendard_regular
                                  .copyWith(color: AppColors.grey_5),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
                        Text(
                          '학교 이메일',
                          style: AppTextStyles.pretendard_regular.copyWith(
                            color: AppColors.grey_5,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 6),

                        Row(
                          children: [
                            Expanded(
                              child: _InputField(
                                controller: emailController,
                                hint: 'student@khu.ac.kr',
                                onChanged: (_) => setState(() {}),
                              ),
                            ),
                            const SizedBox(width: 10),
                            TextButton(
                              onPressed: () {
                                sendEmail();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                                decoration: BoxDecoration(
                                  color: AppColors.main.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  '인증 코드',
                                  style: AppTextStyles.pretendard_regular
                                      .copyWith(
                                    color: AppColors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 6),
                        Text(
                          '학교 도메인 이메일만 가능합니다',
                          style: AppTextStyles.pretendard_regular.copyWith(
                            color: AppColors.grey_5,
                            fontSize: 12,
                          ),
                        ),

                        const SizedBox(height: 20),
                        Text(
                          '인증 코드',
                          style: AppTextStyles.pretendard_regular.copyWith(
                            color: AppColors.grey_5,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 6),
                        _InputField(
                          controller: codeController,
                          hint: '6자리 인증 코드',
                          onChanged: (_) => setState(() {}),
                        ),

                        const Spacer(),

                        GestureDetector(
                          onTap: isFormValid
                              ? () {
                            verifyCode();
                          }
                              : null,
                          child: Container(
                            height: 52,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isFormValid
                                  ? AppColors.main
                                  : AppColors.main.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '인증 확인',
                              style: AppTextStyles.pretendard_regular.copyWith(
                                color: AppColors.white,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final Function(String)? onChanged;

  const _InputField({
    required this.controller,
    required this.hint,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.grey_5.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        cursorColor: AppColors.grey_5,
        style: AppTextStyles.pretendard_regular.copyWith(
          color: AppColors.grey_5,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: AppTextStyles.pretendard_regular.copyWith(
            color: AppColors.grey_5.withOpacity(0.5),
          ),
        ),
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int current;

  const _StepIndicator({required this.current});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 40),
        Icon(Icons.circle,
            color: current >= 1 ? AppColors.main : AppColors.grey_5),
        Expanded(
          child: Container(
            height: 2,
            color: current >= 2 ? AppColors.main : AppColors.grey_5,
          ),
        ),
        Icon(Icons.circle_outlined,
            color: current >= 2 ? AppColors.main : AppColors.grey_5),
        const SizedBox(width: 40),
      ],
    );
  }
}