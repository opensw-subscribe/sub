import 'package:flutter/material.dart';

class WriteSubScreen extends StatefulWidget {
  const WriteSubScreen({super.key});

  @override
  State<WriteSubScreen> createState() => _WriteSubScreenState();
}

class _WriteSubScreenState extends State<WriteSubScreen> {
  final TextEditingController appNameController = TextEditingController();


  String? selectedCategory;


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

  void _submitData() {
    final appName = appNameController.text.trim();
    final category = selectedCategory;

    if (appName.isEmpty || category == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('앱 이름과 카테고리를 모두 입력해주세요.')),
      );
      return;
    }

    print('입력된 앱 이름: $appName');
    print('선택된 카테고리: $category');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('앱 정보가 저장되었습니다!')),
    );

    appNameController.clear();
    setState(() {
      selectedCategory = null;
    });
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
              child: SizedBox(
              height: 56,
              width: double.infinity,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black38),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  selectedCategory ?? '카테고리를 선택하세요',
                  style: TextStyle(
                    fontSize: 16,
                    color: selectedCategory == null
                        ? Colors.grey
                        : Colors.black,
                  ),
                ),
              ),
            ),
            ),
            const SizedBox(height: 32),

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
                  '저장하기',
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
