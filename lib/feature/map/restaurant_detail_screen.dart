import 'package:campit_frontend/feature/map/review_write_screen.dart';
import 'package:campit_frontend/services/map/map_service.dart';
import 'package:campit_frontend/services/storage_service.dart';
import 'package:campit_frontend/shared/ui/buttons/primary_button.dart';
import 'package:campit_frontend/shared/ui/buttons/secondary_button.dart';
import 'package:campit_frontend/shared/ui/custom_dropdown_filter.dart';
import 'package:flutter/material.dart';
import 'package:campit_frontend/shared/constants/app_colors.dart';
import 'package:campit_frontend/shared/constants/app_text_styles.dart';
import 'package:location/location.dart';

class RestaurantDetailScreen extends StatefulWidget {
  final int id;
  final int distance;

  const RestaurantDetailScreen({
    super.key,
    required this.id,
    required this.distance,
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

  @override
  void initState() {
    super.initState();
    // 화면 시작 시 데이터 불러오기
    _fetchAllData();
  }

  // 1. 초기 진입 시: 식당 정보 + 리뷰 정보 동시 호출
  Future<void> _fetchAllData() async {
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

  // UI 정렬 텍스트를 API 파라미터로 변환하는 헬퍼 함수
  void _updateSort(String uiSort) {
    String apiSort = "LATEST";
    switch (uiSort) {
      case "최신순": apiSort = "LATEST"; break;
      case "오래된순": apiSort = "OLDEST"; break;
      case "별점 높은순": apiSort = "RATING_HIGH"; break;
      case "별점 낮은순": apiSort = "RATING_LOW"; break;
      case "좋아요순": apiSort = "LIKES"; break;
    }

    setState(() {
      selectedSortUI = uiSort;
      selectedSortAPI = apiSort;
    });

    // 리뷰 다시 불러오기
    _fetchReviewsOnly();
  }

  // Future<void> fetchRestaurantInfo() async {
  //   // 기본값 설정 (서울시청) - 위치 실패 시 이 값으로 API 호출
  //   double lat = 37.251;
  //   double lng = 127.078;
  //
  //   try {
  //     // 1. 위치 로직 (실패해도 API 호출은 진행하도록 별도 try-catch로 감쌈)
  //     try {
  //       final location = Location();
  //
  //       // 타임아웃을 짧게(3초) 설정하여 무한 로딩 방지
  //       bool serviceEnabled = await location.serviceEnabled();
  //       if (!serviceEnabled) {
  //         serviceEnabled = await location.requestService();
  //       }
  //
  //       if (serviceEnabled) {
  //         PermissionStatus permissionGranted = await location.hasPermission();
  //         if (permissionGranted == PermissionStatus.denied) {
  //           permissionGranted = await location.requestPermission();
  //         }
  //
  //         if (permissionGranted == PermissionStatus.granted) {
  //           // [중요] 타임아웃 추가: 5초 안에 위치 못 가져오면 포기하고 기본값 사용
  //           final locationData = await location.getLocation().timeout(
  //             const Duration(seconds: 5),
  //             onTimeout: () {
  //               print("위치 가져오기 시간 초과 -> 기본 위치 사용");
  //               return LocationData.fromMap({'latitude': lat, 'longitude': lng});
  //             },
  //           );
  //           lat = locationData.latitude ?? lat;
  //           lng = locationData.longitude ?? lng;
  //         }
  //       }
  //     } catch (e) {
  //       print("위치 가져오기 실패 (기본 위치 사용): $e");
  //       // 위치 에러가 나도 무시하고 아래 API 호출로 넘어감
  //     }
  //
  //     print("API 호출 시작: ID=${widget.id}, Lat=$lat, Lng=$lng");
  //
  //     // 2. API 호출
  //     final info = await MapService.fetchRestaurantInfo(
  //       widget.id,
  //       latitude: lat,
  //       longitude: lng,
  //     );
  //
  //     // 3. 상태 업데이트
  //     if (mounted) {
  //       setState(() {
  //         _restaurantInfo = info; // 데이터가 null이어도 로딩은 끝내야 함
  //         _isLoading = false;     // [중요] 로딩 해제
  //       });
  //     }
  //   } catch (e) {
  //     print("전체 로직 에러 발생: $e");
  //     if (mounted) {
  //       setState(() => _isLoading = false); // 에러 발생 시에도 로딩 해제
  //     }
  //   }
  // }

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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _TopBar(),
              const SizedBox(height: 12),

              // 매칭 정보에 데이터 전달 (필요시 수정)
              _MatchCard(info: _restaurantInfo!),

              // 디버깅용 텍스트 (삭제 가능)
              Text("식당 id: ${widget.id.toString()}"),

              const SizedBox(height: 20),

              // 타이틀 섹션에 데이터 전달
              _TitleSection(info: _restaurantInfo!),

              const SizedBox(height: 16),

              // 정보 섹션에 데이터 전달
              _InfoSection(info: _restaurantInfo!, distance: widget.distance),

              const SizedBox(height: 30),
              _ActionButtons(
                id: _restaurantInfo!['placeId'],
                placeName: _restaurantInfo!['placeName'],
              ),
              const SizedBox(height: 32),

              // 리뷰 섹션 (API 응답에 리뷰 리스트가 있다면 여기에 연결)
              _ReviewHeader(
                count: _restaurantInfo!['reviewCount'] ?? 0,
                selected: selectedSortUI,
                onSelected: (value) {
                  setState(() => selectedSortUI = value);
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
            color: AppColors.grey_4,
            size: 20,
          ),
        ),
      ],
    );
  }
}

class _MatchCard extends StatelessWidget {
  final Map<String, dynamic> info;

  const _MatchCard({required this.info}); // 매칭 정보를 받는 생성자


  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // 등급 박스 (Asset 예정)
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.main,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "S",
                    style: AppTextStyles.pretendard_regular.copyWith(color: AppColors.white),
                  ),
                  Text(
                    "등급",
                    style: AppTextStyles.pretendard_regular.copyWith(color: AppColors.white),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 24),

          // 오른쪽 매칭 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "${info['preferencePercent']}%",
                      style: AppTextStyles.pretendard_regular.copyWith(
                        color: AppColors.main,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "매칭",
                      style: AppTextStyles.pretendard_regular.copyWith(color: AppColors.grey_4),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // 게이지(나중에 실제 이미지로 대체)
                SizedBox(
                  height: 40,
                  child: Placeholder(), // 네가 이미지로 교체
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _TitleSection extends StatelessWidget {
  final Map<String, dynamic> info;
  const _TitleSection({required this.info}); // 식당 정보를 받는 생성자

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                info['placeName'] ?? "이름 없음",
                style: AppTextStyles.pretendard_regular.copyWith(
                  color: AppColors.grey_4,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                "(${info['reviewCount']}개 리뷰)",
                style: AppTextStyles.pretendard_regular.copyWith(color: AppColors.grey_4),
              ),
            ],
          ),
          Icon(
            info['isLiked'] == true ? Icons.favorite : Icons.favorite_border,
            size: 20,
            color: info['isLiked'] == true ? AppColors.main : AppColors.grey_4,
          )
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final Map<String, dynamic> info;
  final int distance;
  const _InfoSection({
    required this.info,
    required this.distance,
  }); // 식당 정보를 받는 생성자

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(info['categoryName'] ?? "카테고리 없음",
              style: AppTextStyles.pretendard_regular.copyWith(color: AppColors.grey_4)),
          const SizedBox(height: 8),

          Row(
            children: [
              Icon(Icons.favorite, color: AppColors.main, size: 20),
              const SizedBox(width: 6),
              Text("${info['placeLikeCount']}",
                  style: AppTextStyles.pretendard_regular.copyWith(color: AppColors.grey_4)),            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Icon(Icons.location_on_outlined, color: AppColors.grey_4, size: 20),
              const SizedBox(width: 6),
              Expanded(
                child: Text("${info['roadAddressName']} • ${distance.toString()}m",
                    style: AppTextStyles.pretendard_regular.copyWith(color: AppColors.grey_4)),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Icon(Icons.phone, color: AppColors.grey_4, size: 20),
              const SizedBox(width: 6),
              Text(info['phone'] ?? "전화번호 없음",
                  style: AppTextStyles.pretendard_regular.copyWith(color: AppColors.grey_4)),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Icon(Icons.access_time, color: AppColors.grey_4, size: 20),
              const SizedBox(width: 6),
              Text("11:00 - 21:00",
                  style: AppTextStyles.pretendard_regular.copyWith(color: AppColors.grey_4)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final int id;
  final String placeName;
  const _ActionButtons({
    required this.id,
    required this.placeName
  });

  @override
  Widget build(BuildContext context) {
    LocationData? myLocation;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: PrimaryButton(
              text: "리뷰 작성",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ReviewWriteScreen(
                      placeId: id, // 현재 상세 페이지의 식당 ID
                      placeName: placeName,// 식당 이름
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
              color: AppColors.grey_4,
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

class _ReviewItem extends StatelessWidget {
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
  const _ReviewItem({required this.data}); // 리뷰 데이터를 받는 생성자

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
                  Text(data["nickname"],
                      style: AppTextStyles.pretendard_regular.copyWith(color: AppColors.grey_4)),
                  Text(data["createdAt"],
                      style: AppTextStyles.pretendard_regular.copyWith(color: AppColors.grey_4))
                ],
              )
            ],
          ),

          const SizedBox(height: 12),

          Text(
            data["contents"],
            style: AppTextStyles.pretendard_regular.copyWith(color: AppColors.grey_4),
          ),

          const SizedBox(height: 12),

          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppColors.grey_1,
            ),
            clipBehavior: Clip.hardEdge,
            child: Placeholder(), // 여기 사진 넣으면 됨
          ),

          const SizedBox(height: 10),

          Row(
            children: [
              Icon(Icons.favorite_border, size: 20, color: AppColors.grey_4),
              const SizedBox(width: 4),
              Text(data["likeCount"], style: AppTextStyles.pretendard_regular.copyWith(color: AppColors.grey_4)),
            ],
          ),
        ],
      ),
    );
  }
}

