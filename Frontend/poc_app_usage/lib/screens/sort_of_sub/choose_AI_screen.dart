import 'package:flutter/material.dart';
import 'package:poc_app_usage/screens/choose_fee_screen.dart';
import 'package:poc_app_usage/screens/write_sub_screen.dart';
import '../../utils/logger.dart';

class ChooseAIScreen extends StatelessWidget {
  const ChooseAIScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> buttons = ['ChatGPT', 'Google Gemini', 'Notion', 'Canva'];

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
                    text: ' 님의\nAI 구독 플랫폼을 알려주세요',
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
                                  case 'ChatGPT':
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const ChooseFeeScreen(
                                          platformName: 'ChatGPT',
                                          logoPath: 'assets/logo/chatgpt_logo.png',
                                          feeList: [
                                            'Plus (월 \$20)',
                                            'Pro (월 \$200)',
                                            'Business (월 \$30)',
                                          ],
                                        ),
                                      ),
                                    );
                                    break;

                                  case 'Google Gemini':
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const ChooseFeeScreen(
                                          platformName: 'Google Gemini',
                                          logoPath: 'assets/logo/gemini_logo.png',
                                          feeList: [
                                            'AI Pro (월 29,000원)',
                                            'AI Ultra (월 360,000원)',
                                          ],
                                        ),
                                      ),
                                    );
                                    break;

                                  case 'Notion':
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const ChooseFeeScreen(
                                          platformName: 'Notion',
                                          logoPath: 'assets/logo/notion_logo.png',
                                          feeList: [
                                            'Plus (월 16,800원)',
                                            'Business (월 36,000원)',
                                          ],
                                        ),
                                      ),
                                    );
                                    break;

                                  case 'Canva':
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const ChooseFeeScreen(
                                          platformName: 'Canva',
                                          logoPath: 'assets/logo/canva_logo.png',
                                          feeList: [
                                            'Pro (월 9,900원)',
                                            'Business (월 12,900원)',
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
