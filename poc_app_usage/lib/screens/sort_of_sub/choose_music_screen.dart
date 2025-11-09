import 'package:flutter/material.dart';
import 'package:poc_app_usage/screens/write_sub_screen.dart';
class ChooseMusicScreen extends StatelessWidget {
  const ChooseMusicScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> buttons = ['멜론', '지니뮤직', 'FLO', '벅스', '스포티파이', '애플뮤직'];

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          '구독서비스',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        leading: BackButton(onPressed: () => Navigator.pop(context)),
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '사용자',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A237E),
                      height: 1.2,
                    ),
                  ),
                  const TextSpan(
                    text: ' 님의\n구독 서비스 플랫폼을 알려주세요',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            for (int row = 0; row < 3; row++) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (int col = 0; col < 2; col++)
                    if (row * 2 + col < buttons.length)
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(6.0),
                          child: AspectRatio(
                            aspectRatio: 1.7,
                            child: ElevatedButton(
                              onPressed: () {
                                print('${buttons[row * 2 + col]} 선택됨');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                  side: const BorderSide(color: Colors.black12),
                                ),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: Text(
                                buttons[row * 2 + col],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                    else
                      const Expanded(child: SizedBox()),
                ],
              ),
            ],

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const WriteSubScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: const BorderSide(color: Colors.black12),
                  ),
                ),
                child: const Text(
                  '여기에 없어요 😢',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
