import 'package:campit_frontend/feature/map/review_write_screen.dart';
import 'package:campit_frontend/services/map/map_service.dart';
import 'package:campit_frontend/services/storage_service.dart';
import 'package:campit_frontend/shared/ui/buttons/primary_button.dart';
import 'package:campit_frontend/shared/ui/buttons/secondary_button.dart';
import 'package:campit_frontend/shared/ui/custom_dropdown_filter.dart';
import 'package:campit_frontend/utils/current_position_getter.dart';
import 'package:flutter/material.dart';
import 'package:campit_frontend/shared/constants/app_colors.dart';
import 'package:campit_frontend/shared/constants/app_text_styles.dart';
import 'package:location/location.dart';
import 'package:campit_frontend/utils/location_validator.dart';
import 'package:square_progress_bar/square_progress_bar.dart';

class RestaurantDetailScreen extends StatefulWidget {
  final int id;
  final int distance;
  final String imageUrl;

  const RestaurantDetailScreen({
    super.key,
    required this.id,
    required this.distance,
    required this.imageUrl,
  });

  @override
  State<StatefulWidget> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  String selectedSortUI = "최신순";
  String selectedSortAPI = "LATEST";

  // [추가] 식당 정보를 저장할 변수
  Map<String, dynamic>? _restaurantInfo;
  bool _isLoading = true;
  bool _isReviewLoading = false; // 리뷰만 로딩할 때 사용

  Map<String, dynamic>? _reviewResult; // 리뷰 전체 응답 (content, totalElements 등)
  List<dynamic> _reviews = []; // 실제 리뷰 리스트

  LocationData? _currentLoc;//현재 위치(리뷰 작성 검증용)

  @override
  void initState() {
    super.initState();
    // 화면 시작 시 데이터 불러오기
    _fetchAllData();
  }

  // 1. 초기 진입 시: 식당 정보 + 리뷰 정보 동시 호출
  Future<void> _fetchAllData() async {
    //현재 위치 받아와서 변수에 저장
    _currentLoc = await CurrentPositionGetter.getCurrentPosition();

    // 기본 위치 설정
    double lat = 37.2479;
    double lng = 127.0776;

    try {
      // [중요] 두 API를 병렬로 호출하여 속도 향상
      final results = await Future.wait([
        // 0번 인덱스: 식당 정보
        MapService.fetchRestaurantInfo(widget.id, latitude: lat, longitude: lng),
        // 1번 인덱스: 리뷰 정보 (기본값 LATEST)
        MapService.fetchReviews(widget.id, sort: selectedSortAPI),
      ]);

      if (mounted) {
        setState(() {
          _restaurantInfo = results[0];

          _reviewResult = results[1];
          if (_reviewResult != null) {
            _reviews = _reviewResult!['content'] ?? [];
          }

          _isLoading = false;
        });
      }
    } catch (e) {
      print("전체 데이터 로딩 실패: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 2. 정렬 필터 변경 시: 리뷰만 다시 호출
  Future<void> _fetchReviewsOnly() async {
    if (!mounted) return;
    setState(() => _isReviewLoading = true);

    final result = await MapService.fetchReviews(
      widget.id,
      sort: selectedSortAPI,
    );

    if (mounted) {
      setState(() {
        _reviewResult = result;
        if (result != null) {
          _reviews = result['content'] ?? [];
        }
        _isReviewLoading = false;
      });
    }
  }

  Future<void> _toggleLike() async {
    if (_restaurantInfo == null) return;

    final int placeId = _restaurantInfo!['placeId'];
    final bool currentStatus = _restaurantInfo!['isLiked'] ?? false;
    final int currentCount = _restaurantInfo!['placeLikeCount'] ?? 0;

    // 1. UI 선반영 (Optimistic Update)
    setState(() {
      _restaurantInfo!['isLiked'] = !currentStatus;
      // 좋아요를 눌렀으면 +1, 취소했으면 -1
      _restaurantInfo!['placeLikeCount'] = currentStatus
          ? currentCount - 1
          : currentCount + 1;
    });

    // 2. API 호출
    final success = await MapService.toggleLike(placeId);

    // 3. 실패 시 롤백
    if (!success) {
      if (!mounted) return;
      setState(() {
        _restaurantInfo!['isLiked'] = currentStatus; // 원래대로 복구
        _restaurantInfo!['placeLikeCount'] = currentCount;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('좋아요 처리에 실패했습니다.')),
      );
    }
  }

  // UI 정렬 텍스트를 API 파라미터로 변환하는 헬퍼 함수
  void _updateSort(String uiSort) {
    String apiSort = "LATEST";
    switch (uiSort) {
      case "최신순": apiSort = "LATEST"; break;
      case "오래된순": apiSort = "OLDEST"; break;
      case "별점 높은순": apiSort = "RATING_HIGH"; break;
      case "별점 낮은순": apiSort = "RATING_LOW"; break;
      case "좋아요순": apiSort = "LIKES"; break;
      default:
        print("매칭되는 정렬 없음, 기본값 LATEST 적용");
        apiSort = "LATEST";
    }

    setState(() {
      selectedSortUI = uiSort;
      selectedSortAPI = apiSort;
    });

    // 리뷰 다시 불러오기
    _fetchReviewsOnly();
  }

  @override
  Widget build(BuildContext context) {
    // 로딩 중일 때 표시
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // 데이터가 없을 때 (에러 등)
    if (_restaurantInfo == null) {
      return const Scaffold(
        backgroundColor: AppColors.white,
        body: Center(child: Text("식당 정보를 불러올 수 없습니다.")),
      );
    }

    // 데이터가 있으면 화면 그리기 (기존 코드 + 데이터 바인딩)
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 250, // 원하는 이미지 높이 설정
                  child: Image.network(
                    widget.imageUrl, // 리스트에서 받아온 이미지 URL
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(color: AppColors.grey_1);
                    },
                  ),
                ),

                const SizedBox(height: 8),

                // 타이틀 섹션에 데이터 전달
                _TitleSection(
                  info: _restaurantInfo!,
                  onLikeToggle: _toggleLike,
                ),

                const SizedBox(height: 4),
                _RatingSection(
                  rating: (_restaurantInfo!['averageRating'] ?? 0).toDouble(),
                ),

                const SizedBox(height: 28),

                // 매칭 정보에 데이터 전달 (필요시 수정)
                _MatchCard(info: _restaurantInfo!),

                // 디버깅용 텍스트
                //Text("식당 id: ${widget.id.toString()}"),
                const SizedBox(height: 20),

                // 정보 섹션에 데이터 전달
                _InfoSection(info: _restaurantInfo!, distance: widget.distance, imageUrl: widget.imageUrl),

                const SizedBox(height: 30),
                _ActionButtons(
                  id: _restaurantInfo!['placeId'],
                  placeName: _restaurantInfo!['placeName'],
                  currentLoc: _currentLoc,
                ),
                const SizedBox(height: 32),

                // 리뷰 섹션 (API 응답에 리뷰 리스트가 있다면 여기에 연결)
                _ReviewHeader(
                  count: _restaurantInfo!['reviewCount'] ?? 0,
                  selected: selectedSortUI,
                  onSelected: (value) {
                    _updateSort(value);
                  },
                ),
                const SizedBox(height: 16),
                _isReviewLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildReviewList(),
                const SizedBox(height: 40),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(left: 8, top: 8), // 약간의 여백
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8), // 배경 반투명 흰색
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: AppColors.grey_6,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewList() {
    if (_reviews.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Text("아직 작성된 리뷰가 없습니다."),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: _reviews.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final review = _reviews[index];
        print(review.toString());
        return _ReviewItem(data: review); // _ReviewItem 위젯에 데이터 전달
      },
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
            color: AppColors.grey_5, // grey_4 -> grey_5
            size: 20,
          ),
        ),
      ],
    );
  }
}

class _RatingSection extends StatelessWidget {
  final double rating;

  const _RatingSection({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. 점수 텍스트 (예: 5.0)
          Text(
            rating.toStringAsFixed(1), // 소수점 첫째 자리까지 표시
            style: AppTextStyles.pretendard_regular.copyWith(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.grey_5, // grey_4 -> grey_5
            ),
          ),
          const SizedBox(width: 6),

          // 2. 별 아이콘 5개
          Row(
            children: List.generate(5, (index) {
              // index는 0,1,2,3,4
              // 예: rating이 3.5면 -> 0,1,2는 채워짐 / 3,4는 비워짐
              // (반올림해서 보여주고 싶다면 index < rating.round() 사용)
              return Icon(
                rating.round() >= index + 1 ? Icons.star : Icons.star_border,
                color: AppColors.main, // 메인 컬러 (노란색 계열 예상)
                size: 18,
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _MatchCard extends StatelessWidget {
  final Map<String, dynamic> info;

  const _MatchCard({required this.info}); // 매칭 정보를 받는 생성자


  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "사용자 선호도 반영",
            style: AppTextStyles.pretendard_bold.copyWith(
              color: AppColors.main,
              fontSize: 20
            ),
          ),
          const SizedBox(height: 16),
          SquareProgressBar(
            width: 60, // default: max available space
            height: 60, // default: max available space
            progress: info['preferencePercent'] / 100, // provide the progress in a range from 0.0 to 1.0
            isAnimation: true, // default: false, animate the progress of the bar
            solidBarColor: Colors.amber, // default: blue, main bar color
            emptyBarColor: Colors.orange.withOpacity(0.2), // default: gray, empty bar color
            strokeWidth: 20, // default: 15, bar width
            barStrokeCap: StrokeCap.round, // default: StrokeCap.round, bar cap shape
            isRtl: false, // default: false, bar start point
            gradientBarColor: const LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: <Color>[Colors.red, Colors.amber],
              tileMode: TileMode.repeated,
            ), // default: null, if you pass gradient color it will be used instead of solid color for the main bar
            child: Center(
              child: Text(
                "${info['preferencePercent']}%",
                style: AppTextStyles.pretendard_regular.copyWith(
                  color: AppColors.main,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TitleSection extends StatelessWidget {
  final Map<String, dynamic> info;
  final VoidCallback onLikeToggle;

  const _TitleSection({
    required this.info,
    required this.onLikeToggle,
  }); // 식당 정보를 받는 생성자

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                info['placeName'] ?? "이름 없음",
                style: AppTextStyles.pretendard_bold.copyWith(
                  color: AppColors.grey_6,
                  fontSize: 24,
                ),
              ),
              const SizedBox(width: 4),
              Spacer(),
              GestureDetector(
                onTap: onLikeToggle,
                child: Icon(
                  info['isLiked'] == true ? Icons.favorite : Icons.favorite_border,
                  size: 24,
                  color: info['isLiked'] == true ? AppColors.main : AppColors.grey_5, // grey_4 -> grey_5
                ),
              ),
              const SizedBox(width: 4),
            ],
          ),
          Text(
            info['categoryName'],
            style: AppTextStyles.pretendard_medium.copyWith(
              color: AppColors.grey_4,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final Map<String, dynamic> info;
  final int distance;
  final String imageUrl;

  const _InfoSection({
    required this.info,
    required this.distance,
    required this.imageUrl,
  }); // 식당 정보를 받는 생성자

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image.network(
          //   imageUrl,
          //   height: 200,
          //   width: double.infinity,
          //   fit: BoxFit.cover,
          //   errorBuilder: (context, error, stackTrace) {
          //     return Container(
          //       height: 200,
          //       width: double.infinity,
          //       color: AppColors.grey_1,
          //       child: const Icon(Icons.restaurant, color: Colors.grey),
          //     );
          //   },
          // ),
          const SizedBox(height: 8),

          Row(
            children: [
              Icon(Icons.favorite, color: AppColors.main, size: 20),
              const SizedBox(width: 6),
              Text("${info['placeLikeCount']}",
                  style: AppTextStyles.pretendard_regular.copyWith(color: AppColors.grey_5)), // grey_4 -> grey_5
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Icon(Icons.location_on_outlined, color: AppColors.grey_5, size: 20), // grey_4 -> grey_5
              const SizedBox(width: 6),
              Expanded(
                child: Text("${info['roadAddressName']} • ${distance.toString()}m",
                    style: AppTextStyles.pretendard_regular.copyWith(color: AppColors.grey_5)), // grey_4 -> grey_5
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Icon(Icons.phone, color: AppColors.grey_5, size: 20), // grey_4 -> grey_5
              const SizedBox(width: 6),
              Text(info['phone'] ?? "전화번호 없음",
                  style: AppTextStyles.pretendard_regular.copyWith(color: AppColors.grey_5)), // grey_4 -> grey_5
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Icon(Icons.access_time, color: AppColors.grey_5, size: 20), // grey_4 -> grey_5
              const SizedBox(width: 6),
              Text("11:00 - 21:00",
                  style: AppTextStyles.pretendard_regular.copyWith(color: AppColors.grey_5)), // grey_4 -> grey_5
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButtons extends StatefulWidget {
  final int id;
  final String placeName;
  final LocationData? currentLoc;

  const _ActionButtons({
    required this.id,
    required this.placeName,
    required this.currentLoc,
  });

  @override
  State<_ActionButtons> createState() => _ActionButtonsState();
}

class _ActionButtonsState extends State<_ActionButtons> {
  bool _canWrite = false;

  @override
  void initState() {
    super.initState();
    _checkCanWrite();
  }

  Future<void> _checkCanWrite() async {
    final lat = widget.currentLoc?.latitude;
    final lng = widget.currentLoc?.longitude;

    if (lat == null || lng == null) {
      setState(() {
        _canWrite = false;
      });
      return;
    }

    final result = await LocationValidator.canWritePost(lat, lng);

    if (!mounted) return;

    setState(() {
      _canWrite = result;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: PrimaryButton(
              text: "리뷰 작성",
              onTap: () {

                ///실기기 배포 시 글쓰기 주석 해제하기(에뮬레이터에선 location 문제가 있음)
                // if (!_canWrite) {
                //   // 글쓰기 차단
                //   ScaffoldMessenger.of(context).showSnackBar(
                //     const SnackBar(content: Text('학교 근처에서만 글 작성이 가능합니다')),
                //   );
                //   return;
                // }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ReviewWriteScreen(
                      placeId: widget.id, // 현재 상세 페이지의 식당 ID
                      placeName: widget.placeName,// 식당 이름
                    ),
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
              color: AppColors.grey_5, // grey_4 -> grey_5
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

class _ReviewItem extends StatefulWidget {
  final Map<String, dynamic> data;
  //      {
  //         "reviewId": 1,
  //         "nickname": "캠핑마스터",
  //         "createdAt": "2023-11-27T14:30:00",
  //         "content": "시설이 깨끗하고 음식이 맛있어요!",
  //         "rating": 5,
  //         "imageUrls": [
  //           "string"
  //         ],
  //         "likeCount": 10,
  //         "isMyReview": true,
  //         "isLiked": true
  //       }
  const _ReviewItem({required this.data});
  @override
  State<_ReviewItem> createState() => _ReviewItemState();
}

class _ReviewItemState extends State<_ReviewItem> {
  late bool isLiked;
  late int likeCount;

  @override
  void initState() {
    super.initState();
    // 초기 데이터 설정
    isLiked = widget.data['isLiked'] ?? false;
    likeCount = widget.data['likeCount'] ?? 0;
  }

  // 리뷰 좋아요 토글 로직
  Future<void> _toggleReviewLike() async {
    final int reviewId = widget.data['reviewId'];
    final bool prevLiked = isLiked;
    final int prevCount = likeCount;

    // 1. UI 선반영 (Optimistic Update)
    setState(() {
      isLiked = !isLiked;
      likeCount = isLiked ? likeCount + 1 : likeCount - 1;
    });

    // 2. API 호출
    final success = await MapService.toggleReviewLike(reviewId);

    // 3. 실패 시 롤백
    if (!success) {
      if (!mounted) return;
      setState(() {
        isLiked = prevLiked;
        likeCount = prevCount;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('좋아요 처리에 실패했습니다.')),
      );
    }
  }

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
                  Text(widget.data["nickname"] ?? "nonick",
                      style: AppTextStyles.pretendard_regular.copyWith(color: AppColors.grey_5)), // grey_4 -> grey_5
                  Text(widget.data["createdAt"] ?? "nocrea",
                      style: AppTextStyles.pretendard_regular.copyWith(color: AppColors.grey_5)) // grey_4 -> grey_5
                ],
              )
            ],
          ),

          const SizedBox(height: 12),

          Text(
            widget.data["content"],
            style: AppTextStyles.pretendard_regular.copyWith(color: AppColors.grey_5), // grey_4 -> grey_5
          ),

          const SizedBox(height: 12),

          // 이미지 리스트 처리 로직
          if (widget.data['imageUrls'] != null && (widget.data['imageUrls'] as List).isNotEmpty) ...[
            SizedBox(
              height: 110,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: (widget.data['imageUrls'] as List).length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, imgIndex) {
                  final imageUrl = widget.data['imageUrls'][imgIndex];
                  return Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: AppColors.grey_1,
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(Icons.broken_image, color: Colors.grey),
                        );
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],

          const SizedBox(height: 5), // 이미지와 좋아요 버튼 사이 간격

          GestureDetector(
            onTap: _toggleReviewLike, // 클릭 시 함수 실행
            behavior: HitTestBehavior.opaque, // 터치 영역 확보
            child: Row(
              mainAxisSize: MainAxisSize.min, // 내용물 크기만큼만 차지
              children: [
                Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  size: 20,
                  color: isLiked ? AppColors.main : AppColors.grey_5,
                ),
                const SizedBox(width: 4),
                Text(
                  likeCount.toString(),
                  style: AppTextStyles.pretendard_regular.copyWith(
                    color: isLiked ? AppColors.main : AppColors.grey_5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}