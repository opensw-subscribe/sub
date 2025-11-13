import 'package:flutter/material.dart';
import 'package:poc_app_usage/datas/benefit_data.dart';
import 'package:poc_app_usage/screens/main_screen.dart';
import 'package:flutter/services.dart'; // 숫자 입력 제한용
import 'package:shared_preferences/shared_preferences.dart';

class ChooseFeeScreen extends StatefulWidget {
  final String platformName;
  final String logoPath;
  final List<String> feeList;

  const ChooseFeeScreen({
    super.key,
    required this.platformName,
    required this.logoPath,
    required this.feeList,
  });

  @override
  State<ChooseFeeScreen> createState() => _ChooseFeeScreenState();
}

class _ChooseFeeScreenState extends State<ChooseFeeScreen> {
  String? selectedFee;

  // 혜택 팝업
  void _showBenefitDialog(String fee) {
    final benefit = benefitData[widget.platformName]?[fee] ?? '혜택 정보가 없습니다.';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('$fee 혜택 정보'),
        content: Text(benefit),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }

  // 사용자 입력 팝업
  void _showCustomFeeDialog() {
    final TextEditingController feeController = TextEditingController();
    String selectedCurrency = '₩';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('직접 요금 입력'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Text(
                    '월 ',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: TextField(
                      controller: feeController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ], // 숫자만 입력
                      decoration: InputDecoration(
                        hintText: '금액 입력',
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  DropdownButton<String>(
                    value: selectedCurrency,
                    items: const [
                      DropdownMenuItem(value: '₩', child: Text('₩')),
                      DropdownMenuItem(value: '\$', child: Text('\$')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedCurrency = value!;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final fee = feeController.text.trim();
                if (fee.isEmpty) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(const SnackBar(content: Text('요금을 입력해주세요.')));
                  return;
                }

                // SharedPreferences에 저장
                final prefs = await SharedPreferences.getInstance();
                // 통화 처리: $인 경우 원화로 변환 필요 (예: $20 -> 27000원, 환율은 간단히 1350으로 가정)
                int feeAmount = int.parse(fee);
                if (selectedCurrency == '\$') {
                  feeAmount = (feeAmount * 1350).round(); // 달러를 원화로 변환
                }
                
                await prefs.setString('${widget.platformName}_fee', feeAmount.toString());
                
                print('✅ SharedPreferences 저장 (사용자 입력): ${widget.platformName}_fee = $feeAmount');

                Navigator.pop(context); // 팝업 닫기
                
                if (!mounted) return;
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('요금제 추가 성공')));

                // main_screen으로 이동
                if (!mounted) return;
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MainDashboardScreen(),
                  ),
                  (route) => false,
                );
              },
              child: const Text(
                '추가하기',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          '요금제 선택',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        leading: BackButton(onPressed: () => Navigator.pop(context)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12),

              // 플랫폼 이름
              Text(
                widget.platformName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 24),

              // 로고
              SizedBox(
                height: 120,
                width: 120,
                child: Image.asset(widget.logoPath, fit: BoxFit.contain),
              ),
              const SizedBox(height: 40),

              // 요금제 버튼 목록
              for (final fee in widget.feeList)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(30),
                    onTap: () async {
                      setState(() => selectedFee = fee);
                      print('${widget.platformName} - $fee 선택됨');

                      // 요금제 문자열에서 숫자만 추출 (예: "유튜브 프리미엄 (월 14,900원)" -> "14900")
                      // 쉼표와 모든 비숫자 문자 제거
                      String feeAmount = fee
                          .replaceAll(',', '')  // 쉼표 제거
                          .replaceAll(RegExp(r'[^0-9]'), '')  // 숫자가 아닌 모든 문자 제거
                          .trim();
                      
                      if (feeAmount.isEmpty) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('요금제 금액을 추출할 수 없습니다.')),
                        );
                        print('⚠️ 요금제 금액 추출 실패: $fee');
                        return;
                      }
                      
                      print('💰 추출된 요금: $feeAmount원 (원본: $fee)');

                      // SharedPreferences에 저장
                      final prefs = await SharedPreferences.getInstance();
                      // 키 형식: "플랫폼이름_fee", 값: "금액"
                      await prefs.setString('${widget.platformName}_fee', feeAmount);
                      
                      print('✅ SharedPreferences 저장: ${widget.platformName}_fee = $feeAmount');

                      // 메인 화면으로 이동
                      if (!mounted) return;
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MainDashboardScreen(),
                        ),
                        (route) => false,
                      );
                    },
                    onLongPress: () => _showBenefitDialog(fee),
                    child: Container(
                      height: 55,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selectedFee == fee
                            ? const Color(0xFF1A237E)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.black12),
                      ),
                      child: Text(
                        fee,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: selectedFee == fee
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),

              // 사용자 입력 버튼
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _showCustomFeeDialog,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                        side: const BorderSide(color: Colors.black12),
                      ),
                    ),
                    child: const Text(
                      '사용자 입력',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
