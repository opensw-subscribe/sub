import 'package:flutter/material.dart';
import 'package:poc_app_usage/screens/choose_fee_screen.dart';
import 'package:poc_app_usage/screens/write_sub_screen.dart';
import '../../utils/logger.dart';

class ChooseLifestyleScreen extends StatelessWidget {
  const ChooseLifestyleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> buttons = ['쿠팡', '배달의 민족', '요기요'];

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          '구독 서비스',
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
                    text: ' 님의\n생활 구독 플랫폼을 알려주세요',
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

            for (int row = 0; row < 2; row++) ...[
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
                                final selected = buttons[row * 2 + col];
                                logger.d('$selected 선택됨');

                                switch (selected) {
                                  case '쿠팡':
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const ChooseFeeScreen(
                                          platformName: '쿠팡',
                                          logoPath: 'assets/logo/coupang_logo.png',
                                          feeList: ['쿠팡와우 (월 7,890원)'],
                                        ),
                                      ),
                                    );
                                    break;

                                  case '배달의 민족':
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const ChooseFeeScreen(
                                          platformName: '배달의 민족',
                                          logoPath: 'assets/logo/baemin_logo.png',
                                          feeList: [
                                            '배민클럽 (월 1,990원)',
                                            '배민클럽 + 티빙 (월 5,490원)',
                                            '배민클럽 + 유튜브 프리미엄 (월 13,990원)',
                                          ],
                                        ),
                                      ),
                                    );
                                    break;

                                  case '요기요':
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const ChooseFeeScreen(
                                          platformName: '요기요',
                                          logoPath: 'assets/logo/yogiyo_logo.png',
                                          feeList: [
                                            '요기패스 (월 9,900원)',
                                            '요기패스X (월 2,900원)',
                                          ],
                                        ),
                                      ),
                                    );
                                    break;

                                  default:
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('$selected 화면은 아직 준비 중입니다.')),
                                    );
                                }
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
