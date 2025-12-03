import 'package:flutter/material.dart';
import 'package:poc_app_usage/screens/choose_fee_screen.dart';
import 'package:poc_app_usage/screens/write_sub_screen.dart';
import '../../utils/logger.dart';

class ChooseContentsScreen extends StatelessWidget {
  const ChooseContentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> buttons = [
      '유튜브 프리미엄',
      'Postype',
      '밀리의 서재',
      '리디',
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
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
                    text: ' 님의\n콘텐츠 구독 플랫폼을 알려주세요',
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
                                final selected = buttons[row * 2 + col];
                                logger.d('$selected 선택됨');

                                switch (selected) {
                                  case '유튜브 프리미엄':
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ChooseFeeScreen(
                                          platformName: 'YouTube Premium',
                                          logoPath: 'assets/logo/youtube_logo.png',
                                          feeList: [
                                            '유튜브 프리미엄 (월 14,900원)',
                                          ],
                                        ),
                                      ),
                                    );
                                    break;

                                  case 'Postype':
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ChooseFeeScreen(
                                          platformName: 'Postype',
                                          logoPath: 'assets/logo/postype_logo.png',
                                          feeList: [
                                            '라이트 (월 2,900원)',
                                            '플러스 (월 5,400원)',
                                          ],
                                        ),
                                      ),
                                    );
                                    break;

                                  case '밀리의 서재':
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ChooseFeeScreen(
                                          platformName: 'Millie',
                                          logoPath: 'assets/logo/millie_logo.png',
                                          feeList: [
                                            'Web 구독 (월 11,900원)',
                                            'Google Play 구독 (월 12,900원)',
                                            'Galaxy Store 구독 (월 12,900원)',
                                            '원스토어 구독 (월 11,900원)',
                                          ],
                                        ),
                                      ),
                                    );
                                    break;

                                  case '리디':
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ChooseFeeScreen(
                                          platformName: 'RIDI',
                                          logoPath: 'assets/logo/ridi_logo.png',
                                          feeList: [
                                            '리디셀렉트 (월 4,900원)',
                                          ],
                                        ),
                                      ),
                                    );
                                    break;

                                  default:
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('$selected 화면은 아직 준비 중입니다.'),
                                      ),
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
                    MaterialPageRoute(
                      builder: (context) => const WriteSubScreen(),
                    ),
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
