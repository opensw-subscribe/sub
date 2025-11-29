import 'package:flutter/material.dart';
import 'package:poc_app_usage/screens/choose_platform_screen.dart';
import '../datas/bar_graph_data.dart'; // Statistic 모델 import 필요
import '../service/sub_bar_graph_service.dart'; // StatisticService import 필요

class SubBarGraphScreen extends StatefulWidget {
  final String userId;

  const SubBarGraphScreen({super.key, required this.userId});

  @override
  State<SubBarGraphScreen> createState() => _SubBarGraphScreenState();
}

class _SubBarGraphScreenState extends State<SubBarGraphScreen> {
  // 💡 Statistic -> BarGraphService로 변경됨
  final BarGraphService _service = BarGraphService();
  late Future<List<BarGraphData>> _statisticFuture;
  List<BarGraphData> _statistics = [];

  // 막대 그래프와 목록에 사용될 일관된 색상 정의
  final Color _oncePriceColor = Colors.teal.shade400; // 1회 비용/만족도 막대 (민트색)
  final Color _monthlyPriceColor = Colors.blue.shade900; // 월 비용 막대 (네이비색)

  late final List<Color> _listColors = [_monthlyPriceColor, _oncePriceColor];

  // 현재 월을 YYYY-MM 형식으로 저장
  late String _currentMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentMonth =
        "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}";
    _statisticFuture = _fetchAndGroupDataByMonth();
  }

  Future<List<BarGraphData>> _fetchAndGroupDataByMonth() async {
    final data = await _service.fetchBarGraph(_currentMonth);
    _statistics = data;
    return data;
  }

  Future<void> _updateRating(BarGraphData data, int newRating) async {
    final int oldRating = data.userSatis;
    setState(() => data.userSatis = newRating);

    try {
      await _service.updateRating(
        userId: data.userId,
        appName: data.appName,
        newRating: newRating,
      );
    } catch (e) {
      setState(() => data.userSatis = oldRating);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("별점 수정 실패: $e")));
    }
  }

  // -------------------------
  // UI 구성 요소: 별점 위젯
  // -------------------------
  Widget _buildStarRating({
    required int rating,
    required void Function(int newRating) onChanged,
  }) {
    const double iconSize = 20;
    const Color fillColor = Colors.amber;
    const Color borderColor = Colors.black;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return GestureDetector(
          onTap: () {
            onChanged(index + 1); // 클릭한 위치의 별 개수
          },
          child: SizedBox(
            width: iconSize,
            height: iconSize,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(Icons.star_border, color: borderColor, size: iconSize),
                if (index < rating)
                  Padding(
                    padding: const EdgeInsets.all(1.5),
                    child: Icon(
                      Icons.star,
                      color: fillColor,
                      size: iconSize * 0.7,
                    ),
                  ),
              ],
            ),
          ),
        );
      }),
    );
  }

  // -------------------------
  // UI 구성 요소: 막대 그래프 Placeholder
  // -------------------------
  Widget _buildChartPlaceholder() {
    return Container(
      height: 180,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: _statistics.map((data) => _buildBar(data)).toList(),
      ),
    );
  }

  // -------------------------
  // 개별 막대 위젯 (월 비용/1회 비용을 다른 막대로 표현)
  // -------------------------
  Widget _buildBar(BarGraphData data) {
    const double maxHeight = 120.0;

    // 월 비용 (Monthly Price) - 네이비색 막대
    // Mock 데이터에서 가장 높은 serviceMonthlyPrice인 12000.0을 기준으로 스케일링
    const double maxMonthlyPrice = 12000.0;
    final double monthlyPriceHeight =
        maxHeight * (data.serviceMonthlyPrice / maxMonthlyPrice);

    // 1회 비용 (Once Price) - 민트색 막대 (이미지의 '만족도' 막대로 사용됨)
    // Mock 데이터에서 가장 높은 serviceOncePrice인 1980.0을 기준으로 스케일링
    final double oncePriceHeight =
        maxHeight * (data.serviceOncePrice / maxMonthlyPrice);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: maxHeight,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // 2. 월 비용 막대 (오른쪽, 네이비색)
              _buildSingleBar(
                height: monthlyPriceHeight,
                color: _monthlyPriceColor, // 변수 사용
                maxHeight: maxHeight,
              ),

              const SizedBox(width: 4),

              // 1. 1회 비용 막대 (왼쪽, 민트색)
              _buildSingleBar(
                height: oncePriceHeight,
                color: _oncePriceColor, // 변수 사용
                maxHeight: maxHeight,
              ),
            ],
          ),
        ),
        // ... (Item Name (X축 레이블) 유지)
      ],
    );
  }

  // -------------------------
  // 단일 막대 위젯 (재사용성 향상)
  // -------------------------
  Widget _buildSingleBar({
    required double height,
    required Color color,
    required double maxHeight,
    double width = 10.0,
  }) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        // 배경 (최대 높이)
        Container(width: width, height: maxHeight, color: Colors.grey[200]),
        // 실제 데이터 막대
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ),
      ],
    );
  }

  // -------------------------
  // UI 구성 요소: 목록 항목 위젯
  // -------------------------
  Widget _buildListItem(BarGraphData data) {
    final int index = _statistics.indexOf(data);
    //  목록 점 색상을 월 비용 막대의 색상으로 통일
    final Color listColor = _listColors[index % _listColors.length];

    final String formattedPrice = data.serviceMonthlyPrice
        .toString()
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. 색상 점 (월 비용 색상으로 통일)
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: listColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),

          // 2. 앱 이름 (Expanded로 나머지 공간 모두 확보)
          Expanded(
            child: Text(data.appName, style: const TextStyle(fontSize: 16)),
          ),

          // 3. 별점 표시 (정렬을 위해 고정된 SizedBox 안에 넣습니다)
          //  별점 너비를 고정하여 앱 이름 길이에 상관없이 정렬되도록 함 (대략적인 너비 120.0 사용)
          SizedBox(
            width: 120.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end, // 오른쪽 정렬
              children: [
                _buildStarRating(
                  rating: data.userSatis,
                  onChanged: (newRating) => _updateRating(data, newRating),
                ),
              ],
            ),
          ),

          const SizedBox(width: 30),

          // 4. 월 비용 표시 (Text는 기본적으로 콘텐츠 크기만큼 공간 차지)
          SizedBox(
            width: 70,
            child: Text(
              formattedPrice,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------
  // UI 구성 요소: App Bar
  // -------------------------
  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('Chart', style: TextStyle(fontWeight: FontWeight.bold)),
      centerTitle: true,
      leading: TextButton(
        onPressed: () {
          // Navigator.pop(context); // 임시로 현재 화면 닫기
        },
        child: const Text('설정', style: TextStyle(color: Colors.black)),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ChoosePlatformScreen(),
              ),
            );
          },

          child: const Text('서비스 추가', style: TextStyle(color: Colors.blue)),
        ),
      ],
      backgroundColor: Colors.white,
      elevation: 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: FutureBuilder<List<BarGraphData>>(
        future: _statisticFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('데이터 로드 실패: ${snapshot.error}'));
          }
          if (snapshot.hasData) {
            _statistics = snapshot.data!;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. 막대 그래프 영역
                  _buildChartPlaceholder(),
                  const SizedBox(height: 24),

                  // 2. 목록 제목
                  const Text(
                    '구독 서비스 목록',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  // 3. 서비스 목록
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: _statistics.length,
                    itemBuilder: (context, index) {
                      return _buildListItem(_statistics[index]);
                    },
                  ),
                ],
              ),
            );
          }
          return const Center(child: Text('데이터를 불러올 수 없습니다.'));
        },
      ),
    );
  }
}
/*
}
*/