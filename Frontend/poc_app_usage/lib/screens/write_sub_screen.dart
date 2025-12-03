import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WriteSubScreen extends StatefulWidget {
  const WriteSubScreen({super.key});

  @override
  State<WriteSubScreen> createState() => _WriteSubScreenState();
}

class _WriteSubScreenState extends State<WriteSubScreen> {
  final TextEditingController appNameController = TextEditingController();
  final TextEditingController feeController = TextEditingController();

  String? selectedCategory;
  String selectedCurrency = '₩'; // 기본 통화

  final List<String> categories = [
    'OTT',
    'Music',
    'Contents',
    'Cloud',
    'AI',
    'LifeStyle',
    '기타',
  ];

  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return ListView.builder(
          shrinkWrap: true,
          itemCount: categories.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Center(
                child: Text(
                  categories[index],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              onTap: () {
                setState(() {
                  selectedCategory = categories[index];
                });
                Navigator.pop(context);
              },
            );
          },
        );
      },
    );
  }

  Future<void> _submitData() async {
    final appName = appNameController.text.trim();
    final category = selectedCategory;
    final fee = feeController.text.trim();

    if (appName.isEmpty || category == null || fee.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('앱 이름, 요금제, 카테고리를 모두 입력해주세요.')),
      );
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('${appName}_fee', fee);
      await prefs.setString('${appName}_category', category);

      logger.d('저장 완료: $appName, $fee, $category');

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('앱 정보가 저장되었습니다!')),
      );

      Navigator.pop(context, true); // 성공 시 true 반환
    } catch (e) {
      logger.e('저장 실패: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('저장 중 오류가 발생했습니다: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          '구독 추가하기',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        leading: BackButton(onPressed: () => Navigator.pop(context)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 앱 이름 입력
            const Text(
              '구독한 서비스',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: appNameController,
              decoration: InputDecoration(
                hintText: '앱 이름을 입력하세요',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 요금제 입력
            const Text(
              '요금제',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: feeController,
                    keyboardType: TextInputType.number,
                     inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      hintText: '금액 입력',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
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

            const SizedBox(height: 20),

            // 카테고리 선택
            const Text(
              '카테고리',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            GestureDetector(
              onTap: _showCategoryPicker,
              child: Container(
                height: 56,
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black38),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  selectedCategory ?? '카테고리를 선택하세요',
                  style: TextStyle(
                    fontSize: 16,
                    color: selectedCategory == null ? Colors.grey : Colors.black,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // 저장 버튼
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A237E),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: const BorderSide(color: Colors.black12),
                  ),
                ),
                child: const Text(
                  '추가하기',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
