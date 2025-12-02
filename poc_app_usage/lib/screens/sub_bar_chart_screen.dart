import 'package:flutter/material.dart';
import 'package:poc_app_usage/datas/bar_graph_data.dart';
import 'package:poc_app_usage/screens/choose_platform_screen.dart';
import 'package:poc_app_usage/utils/logger.dart';
import '../service/sub_bar_graph_service.dart'; // StatisticService import 필요

class SubBarGraphScreen extends StatefulWidget {
  const SubBarGraphScreen(String month, {super.key});

  @override
  State<SubBarGraphScreen> createState() => _SubBarGraphScreenState();
}

class _SubBarGraphScreenState extends State<SubBarGraphScreen> {
  // BarGraphService
  final BarGraphService _service = BarGraphService();
  late Future<List<BarGraphData>> _statisticFuture;
  List<BarGraphData> _statistics = [];
  int? _selectedIndex = 0; // 현재 선택된 항목 인덱스, null이면 아무 것도 선택되지 않음

  // 막대 그래프와 목록에 사용될 일관된 색상 정의
  final Color _oncePriceColor = Colors.teal.shade400; // 1회 비용/만족도 막대 (민트색)
  final Color _monthlyPriceColor = Colors.blue.shade900; // 월 비용 막대 (네이비색)

  late final List<Color> _listColors = [_monthlyPriceColor, _oncePriceColor];

  // 요청하는 월을 YYYY-MM 형식으로 저장
  late String _month;

  @override
  void initState() {
    super.initState();

    //무조건 현재 월만을 전달하게 되어있음 수정 필요!!***
    final now = DateTime.now();
    _month =
        "${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}";
    _statisticFuture = _fetchAndGroupDataByMonth();
  }

  Future<List<BarGraphData>> _fetchAndGroupDataByMonth() async {
    final data = await _service.fetchBarGraph(_month);
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
  // 개별 막대 위젯 (월 비용/1회 비용을 다른 막대로 표현)
  // -------------------------
  Widget _buildBar(BarGraphData data) {
    const double maxHeight = 150.0;

    final double maxMonthlyPrice = _statistics.isNotEmpty
        ? _statistics
              .map((e) => e.serviceMonthlyPrice)
              .reduce((a, b) => a > b ? a : b)
              .toDouble()
        : 12000.0;
    final int serviceMonthlyPrice = data.serviceMonthlyPrice;
    final int serviceOncePrice = data.serviceOncePrice;

    final double monthlyPriceHeight =
        maxHeight * (serviceMonthlyPrice / maxMonthlyPrice);
    final double oncePriceHeight =
        maxHeight * (serviceOncePrice / maxMonthlyPrice);

    return SizedBox(
      height: maxHeight + 200, // 막대 + 이름 높이 확보
      child: Center(
        // 전체 영역 중앙
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end, // 막대를 아래쪽 정렬
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildSingleBar(
                  height: monthlyPriceHeight,
                  color: _monthlyPriceColor,
                  maxHeight: maxHeight,
                ),
                const SizedBox(height: 4),
                Text(
                  '월비용:$serviceMonthlyPrice',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            const SizedBox(width: 50),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildSingleBar(
                  height: oncePriceHeight,
                  color: _oncePriceColor,
                  maxHeight: maxHeight,
                ),
                const SizedBox(height: 4),
                Text('일비용:$serviceOncePrice', style: TextStyle(fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------
  // 단일 막대 위젯 (재사용성 향상)
  // -------------------------
  Widget _buildSingleBar({
    required double height,
    required Color color,
    required double maxHeight,
    double width = 15.0,
  }) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        // 배경 (최대 높이)
        Container(
          width: width,
          height: maxHeight + 30,
          color: Colors.grey[200],
        ),
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

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = (_selectedIndex == index)
              ? null
              : index; // 이미 선택된 항목이면 해제
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 1. 색상 점 (월 비용 색상으로 통일)
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: listColor,
                shape: BoxShape.circle,
              ),
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
                    rating: data.userSatis, // ⭐ 각 항목의 개인별 별점 사용!
                    onChanged: (newRating) async {
                      final oldRating = data.userSatis;
                      final oldOncePrice = data.serviceOncePrice;

                      // 1) UI 즉시 반영
                      setState(() => data.userSatis = newRating);

                      try {
                        // 2) 서버 업데이트
                        final updatedOncePrice = await _service.updateRating(
                          userId: data.userId,
                          appName: data.appName,
                          newRating: newRating,
                        );

                        setState(() {
                          // 3) 서버 응답으로 받은 최종 데이터로 객체를 다시 생성하여 리스트에 할당
                          _statistics[index] = _statistics[index].copyWith(
                            serviceOncePrice: updatedOncePrice,
                          );
                          _statistics = List.from(_statistics);
                        });
                      } catch (e) {
                        setState(() {
                          data.userSatis = oldRating; // 실패하면 UI 복원
                          data.serviceOncePrice = oldOncePrice;
                        });
                      }
                    },
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
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
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

          child: const Text('목록편집', style: TextStyle(color: Colors.blue)),
        ),
      ],
      backgroundColor: Colors.white,
      elevation: 0,
    );
  }

  Widget _buildChartForSelected() {
    return SizedBox(
      height: 250, // 막대 영역 전체 높이 지정
      child: Center(
        child: _selectedIndex == null
            ? Text(
                '앱을 선택해주세요',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              )
            : _buildBar(_statistics[_selectedIndex!]),
      ),
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
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('데이터 로드 실패: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('데이터를 불러올 수 없습니다.'));
          }

          _statistics = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. 차트
                Center(child: _buildChartForSelected()),
                const SizedBox(height: 45),

                // 2. 제목
                const Text(
                  '구독 서비스 목록',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),

                // 3. 리스트
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: _statistics.length,
                  itemBuilder: (context, index) =>
                      _buildListItem(_statistics[index]),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
