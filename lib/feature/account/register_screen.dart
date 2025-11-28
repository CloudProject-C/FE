// import 'package:flutter/material.dart';
// import 'package:campit_frontend/shared/constants/app_assets.dart';
// import 'package:campit_frontend/shared/constants/app_colors.dart';
// import 'package:campit_frontend/shared/constants/app_text_styles.dart';
// import 'package:campit_frontend/shared/constants/constants.dart';
// import 'package:dio/dio.dart';
//
// class RegisterScreen extends StatefulWidget {
//   const RegisterScreen({super.key});
//
//   @override
//   State<RegisterScreen> createState() => _RegisterScreenState();
// }
//
// class _RegisterScreenState extends State<RegisterScreen> {
//   // 컨트롤러
//   final _nameController = TextEditingController();
//   final _phoneController = TextEditingController();
//   final _pwController = TextEditingController();
//   final _nicknameController = TextEditingController();
//   final _birthdayController = TextEditingController();
//   final _ageController = TextEditingController();
//   final _familyCodeController = TextEditingController();
//   final _customMemberController = TextEditingController(); // ← 기타 선택 시 상세 입력
//
//   ///final Dio _dio = ApiClient.dio;
//
//   String? _selectedGender;
//   String? _selectedFamilyType;
//   //String? _selectedMemberRole; // 드롭다운에서 선택된 구성원
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       //backgroundColor: AppColors.plumu_white,
//       body: Stack(
//         children: [
//           Center(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.all(20),
//               child: ConstrainedBox(
//                 constraints: const BoxConstraints(maxWidth: 480),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     _buildTextField(_nameController, '이름'),
//                     const SizedBox(height: 12),
//
//                     _buildTextField(
//                       _phoneController,
//                       '전화번호 (예: 010-0000-0000)',
//                       keyboardType: TextInputType.phone,
//                     ),
//                     const SizedBox(height: 12),
//
//                     _buildTextField(_pwController, '비밀번호', obscureText: true),
//                     const SizedBox(height: 12),
//
//                     _buildTextField(_nicknameController, '닉네임'),
//                     const SizedBox(height: 12),
//
//                     _buildTextField(
//                       _birthdayController,
//                       '생년월일',
//                       hint: 'YYYY / MM / DD',
//                     ),
//                     const SizedBox(height: 12),
//
//                     // 성별 선택
//                     SelectableToggleGroup(
//                       title: '성별',
//                       // UI에 보이는 옵션
//                       options: ['남성', '여성'],
//                       // selectedOption은 실제 UI 표시를 위한 매핑 처리
//                       selectedOption: _selectedGender == 'M' ? '남성' : '여성',
//                       onSelect: (value) {
//                         setState(() {
//                           // UI 선택값("남성"/"여성")을 서버용 코드("M"/"F")로 변환
//                           _selectedGender = value == '남성' ? 'M' : 'F';
//                         });
//                       },
//                     ),
//                     const SizedBox(height: 12),
//
//                     _buildTextField(
//                       _ageController,
//                       '나이',
//                       keyboardType: TextInputType.number,
//                     ),
//                     const SizedBox(height: 12),
//
//                     // 가족 선택
//                     SelectableToggleGroup(
//                       title: '가족 선택',
//                       options: ['새로운 가족 생성', '기존 가족 가입'],
//                       selectedOption: _selectedFamilyType ?? '', //null이라면 빈 문자열 전달
//                       onSelect: (value) {
//                         setState(() {
//                           _selectedFamilyType = value;
//                           _familyCodeController.clear();
//                         });
//                       },
//                     ),
//                     const SizedBox(height: 12),
//
//                     // ✅ 기존 가족 가입 시에만 표시
//                     if (_selectedFamilyType == '기존 가족 가입') ...[
//                       _buildTextField(
//                         _familyCodeController,
//                         '가족 인증 코드',
//                       ),
//                       const SizedBox(height: 12),
//                     ],
//
//                     const Text('구성원 선택', style: TextStyle(fontSize: 14)),
//                     const SizedBox(height: 6),
//
//                     const SizedBox(height: 12),
//
//                     // ✅ “기타” 선택 시만 상세 입력란 표시
//                     if (_selectedMemberRole == '기타') ...[
//                       _buildTextField(
//                         _customMemberController,
//                         '상세 역할을 입력하세요 (예: 삼촌, 고모 등)',
//                       ),
//                       const SizedBox(height: 12),
//                     ],
//                     // 회원가입 버튼
//                     CustomButton(text: '회원가입', onPressed: _register),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // 공통 입력 필드
//   Widget _buildTextField(
//       TextEditingController controller,
//       String label, {
//         bool obscureText = false,
//         TextInputType keyboardType = TextInputType.text,
//         String? hint,
//       }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // 상단 라벨
//         Text(
//           label,
//           style: const TextStyle(
//             fontWeight: FontWeight.w600,
//             fontSize: 13,
//           ),
//         ),
//         const SizedBox(height: 6),
//         // 입력 필드
//         TextField(
//           controller: controller,
//           obscureText: obscureText,
//           keyboardType: keyboardType,
//           style: const TextStyle(fontSize: 14),
//           decoration: InputDecoration(
//             hintText: hint,
//             hintStyle: const TextStyle(
//               fontSize: 13,
//               color: Colors.grey,
//             ),
//             contentPadding:
//             const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
//             filled: true,
//             fillColor: Colors.white,
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(6),
//               borderSide: const BorderSide(color: Colors.black12, width: 1),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(6),
//               borderSide: const BorderSide(color: Colors.black45, width: 1.2),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   // 선택형 박스 (성별, 가족유형 공용)
//   Widget _buildSelectableBox({
//     required String label,
//     required bool isSelected,
//     required VoidCallback onTap,
//     bool isLeft = false, // 왼쪽 / 오른쪽 구분용
//     bool isRight = false,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 150),
//         height: 42,
//         alignment: Alignment.center,
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.only(
//             topLeft: isLeft ? const Radius.circular(6) : Radius.zero,
//             bottomLeft: isLeft ? const Radius.circular(6) : Radius.zero,
//             topRight: isRight ? const Radius.circular(6) : Radius.zero,
//             bottomRight: isRight ? const Radius.circular(6) : Radius.zero,
//           ),
//           border: Border.all(
//             color: isSelected ? const Color(0xFF335CB0) : Colors.grey.shade400,
//             width: 1,
//           ),
//         ),
//         child: Text(
//           label,
//           style: TextStyle(
//             color: isSelected ? const Color(0xFF335CB0) : Colors.black87,
//             fontSize: 13,
//             fontWeight: FontWeight.w500,
//           ),
//         ),
//       ),
//     );
//   }
//
//
//
//   void _register() async {
//     // 필수 입력값 확인
//     if (_nameController.text.trim().isEmpty ||
//         _phoneController.text.trim().isEmpty ||
//         _pwController.text.trim().isEmpty ||
//         _nicknameController.text.trim().isEmpty ||
//         _birthdayController.text.trim().isEmpty ||
//         _selectedGender == null ||
//         _ageController.text.trim().isEmpty ||
//         _selectedFamilyType == null ||
//         _selectedMemberRole == null ||
//         // 기존 가족 가입인데 코드가 비어있는 경우
//         (_selectedFamilyType == '기존 가족 가입' &&
//             _familyCodeController.text.trim().isEmpty) ||
//         // 기타 선택인데 상세 역할 미입력
//         (_selectedMemberRole == '기타' &&
//             _customMemberController.text.trim().isEmpty)) {
//       _showErrorDialog("모든 항목을 입력해야 회원가입이 가능합니다.");
//       return;
//     }
//
//     final phone = _phoneController.text.trim();
//     final birthday = _birthdayController.text.trim();
//
//     // ✅ 정규식 패턴 추가
//     final phoneRegex = RegExp(r'^\d{3}-\d{4}-\d{4}$');     // 010-0000-0000
//     final birthdayRegex = RegExp(r'^\d{4}-\d{2}-\d{2}$'); // 2025-10-20
//
//     // 기존 필수 입력값 확인 아래에 추가
//     if (!phoneRegex.hasMatch(phone)) {
//       _showErrorDialog("전화번호 형식이 올바르지 않습니다. (예: 010-0000-0000)");
//       return;
//     }
//
//     if (!birthdayRegex.hasMatch(birthday)) {
//       _showErrorDialog("생년월일 형식이 올바르지 않습니다. (예: 2000-01-01)");
//       return;
//     }
//
//     // 유효성 검사를 통과한 경우만 데이터 전송
//     final data = {
//       "name": _nameController.text.trim(),
//       "phone": _phoneController.text.trim(),
//       "password": _pwController.text.trim(),
//       "nickname": _nicknameController.text.trim(),
//       "birthday": _birthdayController.text.trim(),
//       "gender": _selectedGender,
//       "age": int.tryParse(_ageController.text.trim()) ?? 0,
//       "familyType": _selectedMemberRole == '기타'
//           ? _customMemberController.text.trim()
//           : _selectedMemberRole,
//     };
//
//     // 기존 가족 가입인 경우에만 familyVerificationCode 추가
//     if (_selectedFamilyType == '기존 가족 가입') {
//       data["familyVerificationCode"] = int.tryParse(_familyCodeController.text.trim());
//     } else {
//       data["familyVerificationCode"] = null;
//     }
//
//     print('회원가입 데이터: $data');
//
//     ///서버에 회원가입 요청
//     try {
//       // 실제 API 호출 시도
//       final response = await _dio.post(
//         '$baseUrl/api/signup',
//         data: data,
//       );
//
//       if (response.statusCode == 200) {
//         print('✅ 회원가입 성공');
//         final result = response.data;
//         if (result is String) {
//           print("회원가입 성공: $result");
//         } else {
//           print("회원가입 성공: ${result['message']}");
//         }
//       } else {
//         print('⚠️ 실패: ${response.statusCode}');
//       }
//
//       await Future.delayed(const Duration(milliseconds: 500));
//
//       showSignUpCompleteDialog(context, _phoneController.text.trim(), _pwController.text.trim());
//     } catch (e) {
//       print('❌ 회원가입 오류: $e');
//     }
//   }
//
// // 에러 다이얼로그
//   void _showErrorDialog(String message) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//           title: const Text(
//             "입력 누락",
//             style: TextStyle(fontWeight: FontWeight.bold),
//           ),
//           content: Text(message),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text("확인"),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//
//   @override
//   void dispose() {
//     _nameController.dispose();
//     _phoneController.dispose();
//     _pwController.dispose();
//     _nicknameController.dispose();
//     _birthdayController.dispose();
//     _ageController.dispose();
//     _familyCodeController.dispose();
//     _customMemberController.dispose();
//     super.dispose();
//   }
// }
//
// class SelectableToggleGroup extends StatelessWidget {
//   final String title; // 상단 라벨 (예: "성별")
//   final List<String> options; // 선택 가능한 항목들
//   final String selectedOption; // 현재 선택된 항목
//   final ValueChanged<String> onSelect; // 선택 시 콜백
//
//   const SelectableToggleGroup({
//     super.key,
//     required this.title,
//     required this.options,
//     required this.selectedOption,
//     required this.onSelect,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           title,
//           style: const TextStyle(
//             fontWeight: FontWeight.w600,
//             fontSize: 13,
//           ),
//         ),
//         const SizedBox(height: 6),
//         Container(
//           height: 42,
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(3),
//             border: Border.all(color: Colors.black12, width: 1.3),
//           ),
//           child: Row(
//             children: List.generate(options.length, (index) {
//               final label = options[index];
//               final isSelected = label == selectedOption;
//
//               return Expanded(
//                 child: GestureDetector(
//                   onTap: () => onSelect(label),
//                   child: Container(
//                     alignment: Alignment.center,
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       border: Border(
//                         right: index != options.length - 1
//                             ? BorderSide(color: Colors.grey.shade400, width: 1)
//                             : BorderSide.none,
//                       ),
//                     ),
//                     child: Text(
//                       label,
//                       style: TextStyle(
//                         color: isSelected
//                             ? AppColors
//                             : Colors.black87,
//                         fontSize: 13,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ),
//                 ),
//               );
//             }),
//           ),
//         ),
//       ],
//     );
//   }
// }