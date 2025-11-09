import 'package:flutter/material.dart';
import '../datas/bar_graph_data.dart'; // Statistic 모델 import 필요
import '../service/sub_bar_graph_service.dart'; // StatisticService import 필요

class SubChartScreen extends StatefulWidget {
  final String userId; 

  const SubChartScreen({super.key, required this.userId});

  @override
  State<SubChartScreen> createState() => _SubChartScreenState();
}

class _SubChartScreenState extends State<SubChartScreen> {
  final StatisticService _service = StatisticService();
  late Future<List<Statistic>> _statisticFuture;
  List<Statistic> _statistics = [];

  @override
  void initState() {
    super.initState();
    _statisticFuture = _service.fetchStatistics(widget.userId);
}

  // -------------------------
  // UI 구성 요소: 별점 위젯 (Chart Mode 전용)
  // -------------------------
  Widget _buildStarRating(int rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          color: index < rating ? Colors.amber : Colors.grey[300],
          size: 20,
        );
      }),
    );
  }
  
  // -------------------------
  // UI 구성 요소: 막대 그래프 Placeholder
  // -------------------------
  Widget _buildChartPlaceholder() {
    // 만족도와 가격을 시각화한 막대 그래프 Placeholder (이미지 2aa498.png 참조)
    return Container(
      height: 180,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 2, blurRadius: 5)],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: _statistics.map((data) => _buildBar(data)).toList(),
      ),
    );
  }

  // 개별 막대 위젯
  Widget _buildBar(Statistic data) {
    // 막대 높이: 만족도(1-5)를 기반으로 비율 계산
    final double ratingFactor = data.userSatis / 5.0; 
    const double maxHeight = 120.0;
    final double ratingHeight = maxHeight * ratingFactor;
    
    // 가격을 기반으로 색상 분할 (Placeholder)
    final Color color1 = Colors.teal.shade400; // 만족도 부분 색상
    final Color color2 = Colors.blue.shade900; // 가격 부분 색상
    
    // 가격에 비례하여 막대 높이 계산 (여기서는 만족도와 섞어서 임시 시각화)
    final double priceFactor = data.serviceMonthlyPrice / 20000; // 최대 가격 20000원 가정
    final double priceHeight = maxHeight * priceFactor * 0.5; // 절반 비율 적용

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: maxHeight,
          width: 20,
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              // 배경 (최대 높이)
              Container(width: 20, height: maxHeight, color: Colors.grey[200]),
              // 만족도 시각화 부분 (상단)
              Positioned(
                bottom: 0,
                child: Container(
                  width: 20, 
                  height: ratingHeight, 
                  decoration: BoxDecoration(
                    color: color1, 
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4))
                  )
                )
              ),
              // 가격 시각화 부분 (하단) - 만족도 막대 위에 겹쳐서 표시
              Positioned(
                bottom: 0,
                child: Container(
                  width: 20, 
                  height: priceHeight, 
                  color: color2, 
                )
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        // Item Name (X축 레이블)
        Text(data.appName.substring(0, 4) + '.', style: TextStyle(fontSize: 10, color: Colors.grey[600])),
      ],
    );
  }

  // -------------------------
  // UI 구성 요소: 목록 항목 위젯
  // -------------------------
  Widget _buildListItem(Statistic data) {
    final Color itemColor = data.appCategory == 'Music' ? Colors.blue[800]! : Colors.teal;
    
    // 🚨 수정: serviceMonthlyPrice만 사용합니다.
    final String formattedPrice = data.serviceMonthlyPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: itemColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          
          Expanded(
            child: Text(data.appName, style: const TextStyle(fontSize: 16)),
          ),
          
          // 별점 표시
          _buildStarRating(data.userSatis),
          
          const SizedBox(width: 24),
          
          // 월 비용 표시 (serviceMonthlyPrice)
          Text(formattedPrice, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // -------------------------
  // UI 구성 요소: App Bar (Chart 모드 전용)
  // -------------------------
  AppBar _buildAppBar() {
    return AppBar(
      title: const Text('Chart', style: TextStyle(fontWeight: FontWeight.bold)),
      centerTitle: true,
      leading: TextButton(
        onPressed: () {
          // '설정' 화면으로 이동하거나 What-If 모드로 전환하는 로직
          // MainDashboardScreen이 Stateful이라면 여기서 상태를 변경합니다.
          Navigator.pop(context); // 임시로 현재 화면 닫기 (MainDashboardScreen으로 돌아감)
        },
        child: const Text('설정', style: TextStyle(color: Colors.black)),
      ),
      actions: [
        TextButton(
          onPressed: () {
            // '서비스 추가' 화면으로 이동하는 기능
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
      body: FutureBuilder<List<Statistic>>(
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
                  const Text('구독 서비스 목록', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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