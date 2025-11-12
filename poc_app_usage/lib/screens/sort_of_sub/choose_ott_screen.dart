import 'package:flutter/material.dart';
import 'package:poc_app_usage/screens/write_sub_screen.dart';
import 'package:poc_app_usage/screens/choose_fee_screen.dart';

class ChooseOTTScreen extends StatelessWidget {
  const ChooseOTTScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> buttons = ['넷플릭스', '디즈니+', '웨이브', '티빙', '왓챠', '쿠팡플레이'];

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
                    text: ' 님의\nOTT 구독 플랫폼을 알려주세요',
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
                                print('$selected 선택됨');

                                switch (selected) {
                                  case '넷플릭스':
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ChooseFeeScreen(
                                          platformName: 'Netflix',
                                          logoPath: 'assets/logo/netflix_logo.png',
                                          feeList: [
                                            '광고형 스탠다드 (월 7,000원)',
                                            '스탠다드 (월 13,500원)',
                                            '프리미엄 (월 17,000원)',
                                          ],
                                        ),
                                      ),
                                    );
                                    break;

                                  case '디즈니+':
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ChooseFeeScreen(
                                          platformName: 'Disney+',
                                          logoPath: 'assets/logo/disneyplus_logo.png',
                                          feeList: [
                                            '스탠다드 (월 9,900원)',
                                            '프리미엄 (월 13,900원)',
                                          ],
                                        ),
                                      ),
                                    );
                                    break;

                                  case '웨이브':
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ChooseFeeScreen(
                                          platformName: 'Wavve',
                                          logoPath: 'assets/logo/wavve_logo.png',
                                          feeList: [
                                            '광고형 스탠다드 (월 5,500원)',
                                            '베이직 (월 7,900원)',
                                            '스탠다드 (월 10,900원)',
                                            '프리미엄 (월 13,900원)',
                                          ],
                                        ),
                                      ),
                                    );
                                    break;

                                  case '티빙':
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ChooseFeeScreen(
                                          platformName: 'TVING',
                                          logoPath: 'assets/logo/tving_logo.png',
                                          feeList: [
                                            '광고형 스탠다드 (월 5,500원)',
                                            '베이직 (월 9,500원)',
                                            '스탠다드 (월 13,500원)',
                                            '프리미엄 (월 17,000원)',
                                          ],
                                        ),
                                      ),
                                    );
                                    break;

                                  case '왓챠':
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ChooseFeeScreen(
                                          platformName: 'WATCHA',
                                          logoPath: 'assets/logo/watcha_logo.png',
                                          feeList: [
                                            '베이직 (월 7,900원)',
                                            '프리미엄 (월 12,900원)',
                                          ],
                                        ),
                                      ),
                                    );
                                    break;

                                  case '쿠팡플레이':
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ChooseFeeScreen(
                                          platformName: 'Coupang Play',
                                          logoPath: 'assets/logo/coupangplay_logo.png',
                                          feeList: [
                                            '쿠팡와우 (월 7,890원)',
                                            '와우+스포츠 패스 (월 17,790원)',
                                            '스포츠 패스 (월 16,600원)',
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
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
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
