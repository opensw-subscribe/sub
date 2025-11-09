import 'package:flutter/material.dart';
import 'package:poc_app_usage/screens/sort_of_sub/choose_ott_screen.dart';
import 'package:poc_app_usage/screens/sort_of_sub/choose_music_screen.dart';
import 'package:poc_app_usage/screens/sort_of_sub/choose_contents_screen.dart';
import 'package:poc_app_usage/screens/sort_of_sub/choose_cloud_screen.dart';
import 'package:poc_app_usage/screens/sort_of_sub/choose_ai_screen.dart';
import 'package:poc_app_usage/screens/sort_of_sub/choose_lifestyle_screen.dart';
import 'package:poc_app_usage/screens/write_sub_screen.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: SubscriptionScreen(),
  ));
}

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> buttons = ['OTT', 'Music', 'Contents', 'Cloud', 'AI', 'LifeStyle'];

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          '구독서비스',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        leading: BackButton(onPressed: () => Navigator.pop(context)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text.rich(
              const TextSpan(
                children: [
                  TextSpan(
                    text: '사용자',
                    style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A237E),
                        height: 1.2),
                  ),
                  TextSpan(
                    text: ' 님의\n구독 서비스 플랫폼을 알려주세요',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // 6개 버튼
            for (int row = 0; row < 3; row++)
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
                                final label = buttons[row * 2 + col];

                               
                                if (label == 'OTT') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const ChooseOTTScreen(),
                                    ),
                                  );
                                } else if (label == 'Music') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const ChooseMusicScreen(),
                                    ),
                                  );
                                } else if (label == 'Contents') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const ChooseContentsScreen(),
                                    ),
                                  );
                                } else if (label == 'Cloud') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const ChooseCloudScreen(),
                                    ),
                                  );
                                } else if (label == 'AI') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const ChooseAIScreen(),
                                    ),
                                  );
                                } else if (label == 'LifeStyle') {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const ChooseLifestyleScreen(),
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
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ),
                ],
              ),

            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WriteSubScreen(), // 나중에 RequestSubScreen
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 20 ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15),side: const BorderSide(color: Colors.black12),),
              ),
              child: const Text('여기에 없어요 😢',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold )),
            ),
          ],
        ),
      ),
    );
  }
}