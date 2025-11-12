import 'package:flutter/material.dart';
import 'package:poc_app_usage/data/benefit_data.dart';
import 'package:poc_app_usage/screens/main_screen.dart';
import 'package:flutter/services.dart'; // 숫자 입력 제한용

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

  void _onNextPressed() {
    if (selectedFee == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('요금제를 선택해주세요.')),
      );
      return;
    }
    print('${widget.platformName} - 선택된 요금제: $selectedFee');
  }

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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('직접 요금 입력'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Text(
                    '월 ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: feeController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly], // 숫자만 입력
                      decoration: InputDecoration(
                        hintText: '금액 입력',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
              onPressed: () {
                final fee = feeController.text.trim();
                if (fee.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('요금을 입력해주세요.')),
                  );
                  return;
                }

                Navigator.pop(context); // 팝업 닫기
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('요금제 추가 성공')),
                );

                // main_screen으로 이동
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const MainDashboardScreen()),
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
                child: Image.asset(
                  widget.logoPath,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 40),

              // 요금제 버튼 목록
              for (final fee in widget.feeList)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(30),
                    onTap: () {
                      setState(() => selectedFee = fee);
                      print('${widget.platformName} - $fee 선택됨');
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
