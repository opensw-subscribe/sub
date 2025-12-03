import 'package:flutter/material.dart';
import 'package:poc_app_usage/screens/choose_fee_screen.dart';
import 'package:poc_app_usage/screens/write_sub_screen.dart';
import '../../utils/logger.dart';

class ChooseMusicScreen extends StatelessWidget {
  const ChooseMusicScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> buttons = ['멜론', '지니뮤직', 'FLO', '벅스', '스포티파이', '애플뮤직'];

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
                    text: ' 님의\n음악 구독 플랫폼을 알려주세요',
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

            for (int row = 0; row < 4; row++) ...[
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
                                  case '멜론':
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ChooseFeeScreen(
                                          platformName: 'Melon',
                                          logoPath: 'assets/logo/melon_logo.png',
                                          feeList: [
                                            '스트리밍 클럽 (월 6,900원)',
                                            '스트리밍 플러스 (월 11,400원)',
                                          ],
                                        ),
                                      ),
                                    );
                                    break;

                                  case '지니뮤직':
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ChooseFeeScreen(
                                          platformName: 'Genie',
                                          logoPath: 'assets/logo/geniemusic_logo.png',
                                          feeList: [
                                            '스마트 음악감상 (월 7,900원)',
                                            '음악감상 (월 8,400원)',
                                            '데이터 세이프 음악감상 (월 10,900원)',
                                            '초고음질 음악감상 (월 14,000원)',
                                          ],
                                        ),
                                      ),
                                    );
                                    break;

                                  case 'FLO':
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ChooseFeeScreen(
                                          platformName: 'FLO',
                                          logoPath: 'assets/logo/flo_logo.png',
                                          feeList: [
                                            '모바일 무제한 듣기 (월 6,900원)',
                                            '무제한 듣기 (월 7,900원)',
                                            '무제한 듣기+오프라인 재생 (월 10,900원)',                                          
                                          ],
                                        ),
                                      ),
                                    );
                                    break;

                                  case '벅스':
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ChooseFeeScreen(
                                          platformName: 'Bugs',
                                          logoPath: 'assets/logo/bugs_logo.png',
                                          feeList: [
                                            '모바일 무제한 듣기 (월 6,900원)',
                                            '무제한 듣기 (월 7,900원)',
                                            '무제한 듣기 + 오프라인 재생 (월 10,900원)',
                                            'Premium 무제한 듣기 (월 12,000원)',
                                            'Premium 무제한 듣기 + 오프라인 재생 (월 16,000원)',                                         
                                          ],
                                        ),
                                      ),
                                    );
                                    break;

                                  case '스포티파이':
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ChooseFeeScreen(
                                          platformName: 'Spotify',
                                          logoPath: 'assets/logo/spotify_logo.png',
                                          feeList: [
                                            '베이직 (월 8,690원)',
                                            '개인 (월 11,900원)',
                                            '듀오 (월 17,985원)',
                                          ],
                                        ),
                                      ),
                                    );
                                    break;

                                  case '애플뮤직':
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ChooseFeeScreen(
                                          platformName: 'Apple Music',
                                          logoPath: 'assets/logo/applemusic_logo.png',
                                          feeList: [
                                            '개인 (월 8,900원)',
                                            '가족 (월 13,500원)',
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
