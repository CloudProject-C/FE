import 'dart:io';
import 'package:campit_frontend/shared/ui/buttons/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:campit_frontend/shared/constants/app_colors.dart';
import 'package:campit_frontend/shared/constants/app_text_styles.dart';

class ReviewWriteScreen extends StatefulWidget {
  final int placeId;
  final String placeName;
  const ReviewWriteScreen({
    super.key,
    required this.placeId,
    required this.placeName,
  });

  @override
  State<ReviewWriteScreen> createState() => _ReviewWriteScreenState();
}

class _ReviewWriteScreenState extends State<ReviewWriteScreen> {
  final TextEditingController _contentController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  int _contentLength = 0;
  int _rating = 0;
  List<XFile> _images = [];

  @override
  void initState() {
    super.initState();
    _contentController.addListener(_updateCount);
  }

  @override
  void dispose() {
    _contentController.removeListener(_updateCount);
    _contentController.dispose();
    super.dispose();
  }

  void _updateCount() {
    setState(() {
      _contentLength = _contentController.text.length;
    });
  }

  Future<void> _pickImage() async {
    if (_images.length >= 5) return;

    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (picked != null) {
      setState(() => _images.add(picked));
    }
  }

  void _removeImage(int index) {
    setState(() => _images.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: AppColors.white,
        appBar: AppBar(
          title: Text(
            '리뷰 작성',
            style: AppTextStyles.pretendard_regular.copyWith(
              color: AppColors.grey_4,
            ),
          ),
          backgroundColor: AppColors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: AppColors.grey_4),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 상단 식당 정보
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.grey_4.withOpacity(0.2)),
                  ),
                  child: Text(
                    '경희 떡볶이\n작성 가능 (학교 500m 이내)',
                    style: AppTextStyles.pretendard_regular
                        .copyWith(color: AppColors.grey_4),
                  ),
                ),

                const SizedBox(height: 24),

                // 글자수 실시간 반영
                Text(
                  '리뷰 작성 ($_contentLength/1000)',
                  style: AppTextStyles.pretendard_regular
                      .copyWith(color: AppColors.grey_4),
                ),
                const SizedBox(height: 8),

                // 리뷰 입력창
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.grey_4.withOpacity(0.2)),
                  ),
                  child: TextField(
                    controller: _contentController,
                    maxLines: 8,
                    maxLength: 1000,
                    style: AppTextStyles.pretendard_regular
                        .copyWith(color: AppColors.grey_4),
                    decoration: InputDecoration(
                      hintText: '음식점에 대한 솔직한 리뷰를 작성해주세요',
                      hintStyle: AppTextStyles.pretendard_regular
                          .copyWith(color: AppColors.grey_4.withOpacity(0.5)),
                      border: InputBorder.none,
                      counterText: '',
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // 별점
                Text(
                  '별점',
                  style: AppTextStyles.pretendard_regular
                      .copyWith(color: AppColors.grey_4),
                ),
                const SizedBox(height: 8),

                Row(
                  children: List.generate(5, (index) {
                    final starValue = index + 1;
                    return GestureDetector(
                      onTap: () => setState(() => _rating = starValue),
                      child: Icon(
                        Icons.star,
                        size: 28,
                        color: starValue <= _rating
                            ? AppColors.main
                            : AppColors.grey_4,
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 4),
                Text(
                  '$_rating',
                  style: AppTextStyles.pretendard_regular
                      .copyWith(color: AppColors.grey_4),
                ),

                const SizedBox(height: 24),

                // 사진
                Text(
                  '사진 (${_images.length}/5)',
                  style: AppTextStyles.pretendard_regular
                      .copyWith(color: AppColors.grey_4),
                ),
                const SizedBox(height: 12),

                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 96,
                        width: 96,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.grey_4.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate,
                                size: 32, color: AppColors.grey_4),
                            const SizedBox(height: 4),
                            Text(
                              '추가',
                              style: AppTextStyles.pretendard_regular
                                  .copyWith(color: AppColors.grey_4),
                            ),
                          ],
                        ),
                      ),
                    ),

                    ..._images.asMap().entries.map((entry) {
                      final index = entry.key;
                      final file = entry.value;

                      return Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              File(file.path),
                              width: 96,
                              height: 96,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            right: 4,
                            top: 4,
                            child: GestureDetector(
                              onTap: () => _removeImage(index),
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.close,
                                  size: 16,
                                  color: AppColors.grey_4,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),

                const SizedBox(height: 12),

                Text(
                  '최대 5장, 각 5MB 이하',
                  style: AppTextStyles.pretendard_regular
                      .copyWith(color: AppColors.grey_4.withOpacity(0.5)),
                ),

                const SizedBox(height: 40),

                PrimaryButton(
                    text: '리뷰 등록하기',
                    onTap: (){
                      Navigator.pop(context);
                      //TODO: 리뷰 등록 로직
                    },
                    height: 48,
                    width: double.infinity
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
