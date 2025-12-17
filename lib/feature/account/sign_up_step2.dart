import 'package:campit_frontend/feature/account/onboard_preference_screen.dart';
import 'package:campit_frontend/services/storage_service.dart';
import 'package:campit_frontend/shared/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:campit_frontend/shared/constants/app_colors.dart';
import 'package:campit_frontend/shared/constants/app_text_styles.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SignUpStep2Screen extends StatefulWidget {
  final int schoolId;
  final String email;
  const SignUpStep2Screen({
    super.key,
    required this.schoolId,
    required this.email,
  });

  @override
  State<SignUpStep2Screen> createState() => _SignUpStep2ScreenState();
}

class _SignUpStep2ScreenState extends State<SignUpStep2Screen> {
  final nicknameController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordCheckController = TextEditingController();

  bool hidePw = true;
  bool hidePwCheck = true;

  bool get isValid =>
      nicknameController.text.isNotEmpty &&
          passwordController.text.length >= 4 &&
          passwordCheckController.text == passwordController.text;

  void register() async{
    try{
      final _schoolId = widget.schoolId;
      final _email = widget.email;
      final _nickname = nicknameController.text.trim();
      final _password = passwordController.text.trim();
      final _passwordCheck = passwordCheckController.text.trim();
      final _profileImage = 'exampleImageUrl';
      final _gender = 'MALE';

      if (_password.toString() != _passwordCheck.toString()) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('비밀번호와 비밀번호 확인이 일치하지 않습니다.'),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      if (_nickname.isEmpty || _password.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('닉네임과 비밀번호를 모두 입력하세요.'),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      final registerUri = Uri.parse('$baseUrl/join').toString();
      final response = await http.post(
        Uri.parse(registerUri),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'schoolId': _schoolId,
          'email': _email,
          'password': _password,
          'nickname': _nickname,
          'profileImage': _profileImage,
          'gender': _gender
        }),
      );

      print(response.body);

      if (response.statusCode == 200) {
        //Navigator.pushNamed(context, '/login');
        autoLogin();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('회원가입에 실패했습니다.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('회원가입 처리 중 오류가 발생했습니다: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
      debugPrint('register Error: $e');
    }
  }

  void autoLogin() async {
    final email = widget.email;
    final password = passwordController.text.trim();
    debugPrint('AutoLogin Attempt: email: $email, PW: $password');

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('자동 로그인 중 오류: 이메일 또는 비밀번호가 비었습니다.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    try{
      // 1. 로그인 API 호출
      final loginUri = Uri.parse('$baseUrl/login').toString();

      final response = await http.post(
        Uri.parse(loginUri),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("data is ${data.toString()}");
        final accessToken = data['result'].toString();
        debugPrint('-----autoLogin response is: ${response.body}-----');

        // 2. 토큰 저장
        await StorageService.saveAccessToken(accessToken);

        print("-----my access token is: $accessToken-----");

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OnboardFoodPreferenceScreen(
                nickname: nicknameController.text.trim()
            )
          ),
        );
      } else {
        //throw Exception('Login failed: ${response.statusCode}');
        ///throw Exception 대신 email, pw일치하지 않다는 ui바를 호출
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('autologin: 이메일 또는 비밀번호가 일치하지 않습니다.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('로그인 중 오류가 발생했습니다: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
      debugPrint('Login Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true, // 키보드 올라오면 화면 줄어듦
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
            ),
          ),
        ),
        // [수정] LayoutBuilder + SingleChildScrollView 구조 적용
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight, // 최소 높이를 화면 전체로 설정
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        _StepIndicator(current: 2),
                        const SizedBox(height: 40),

                        Text(
                          '추가 정보 입력',
                          style: AppTextStyles.pretendard_regular.copyWith(
                            color: AppColors.grey_5,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '거의 다 됐어요!',
                          style: AppTextStyles.pretendard_regular.copyWith(
                            color: AppColors.grey_5.withOpacity(0.7),
                            fontSize: 14,
                          ),
                        ),

                        const SizedBox(height: 30),

                        Text(
                          '닉네임',
                          style: AppTextStyles.pretendard_regular.copyWith(
                            color: AppColors.grey_5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        _InputField(
                          controller: nicknameController,
                          hint: '2-10자 이내',
                          onChanged: (_) => setState(() {}),
                        ),

                        const SizedBox(height: 20),

                        Text(
                          '비밀번호',
                          style: AppTextStyles.pretendard_regular.copyWith(
                            color: AppColors.grey_5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        _InputField(
                          controller: passwordController,
                          hint: '4자 이상',
                          obscure: hidePw,
                          onSuffixTap: () {
                            setState(() => hidePw = !hidePw);
                          },
                          onChanged: (_) => setState(() {}),
                        ),

                        const SizedBox(height: 20),

                        Text(
                          '비밀번호 확인',
                          style: AppTextStyles.pretendard_regular.copyWith(
                            color: AppColors.grey_5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        _InputField(
                          controller: passwordCheckController,
                          hint: '비밀번호 재입력',
                          obscure: hidePwCheck,
                          onSuffixTap: () {
                            setState(() => hidePwCheck = !hidePwCheck);
                          },
                          onChanged: (_) => setState(() {}),
                        ),

                        const Spacer(), // 남은 공간 차지 (키보드 올라오면 스크롤 됨)

                        TextButton(
                          onPressed: () {
                            register();
                          },
                          child: Container(
                            height: 52,
                            decoration: BoxDecoration(
                              color: isValid
                                  ? AppColors.main
                                  : AppColors.main.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '가입 완료',
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

// ... _InputField, _StepIndicator 클래스는 기존과 동일 ...
class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final Function(String)? onChanged;
  final bool obscure;
  final Function()? onSuffixTap;

  const _InputField({
    required this.controller,
    required this.hint,
    this.onChanged,
    this.obscure = false,
    this.onSuffixTap,
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
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              obscureText: obscure,
              cursorColor: AppColors.grey_5,
              style: AppTextStyles.pretendard_regular.copyWith(
                color: AppColors.grey_5,
              ),
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
                hintStyle: AppTextStyles.pretendard_regular.copyWith(
                  color: AppColors.grey_5.withOpacity(0.5),
                ),
              ),
            ),
          ),
          if (onSuffixTap != null)
            GestureDetector(
              onTap: onSuffixTap,
              child: Icon(
                obscure ? Icons.visibility_off : Icons.visibility,
                color: AppColors.grey_5,
                size: 20,
              ),
            ),
        ],
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
        Icon(Icons.check_circle,
            color: current >= 1 ? AppColors.main : AppColors.grey_5),
        Expanded(
          child: Container(
            height: 2,
            color: current >= 2 ? AppColors.main : AppColors.grey_5,
          ),
        ),
        Icon(Icons.circle,
            color: current >= 2 ? AppColors.main : AppColors.grey_5),
        const SizedBox(width: 40),
      ],
    );
  }
}