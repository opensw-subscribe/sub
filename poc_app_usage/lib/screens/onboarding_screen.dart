import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:poc_app_usage/screens/login_screen.dart'; 
import 'package:poc_app_usage/screens/signup_screen.dart'; 

enum EmojiPosition { belowDescription, bottomRightOfPhone, middleRightOfPhone }

// 각 슬라이드의 내용물
class OnboardingItem {
  final String mainTitle;
  final String description;
  final String emoji;
  final String imagePath;
  final EmojiPosition emojiPosition;

  OnboardingItem({
    required this.mainTitle,
    required this.description,
    required this.emoji,
    required this.imagePath,
    required this.emojiPosition,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  // 1. 슬라이드 3페이지의 내용 정의
  final List<OnboardingItem> _items = [
    OnboardingItem(
      mainTitle: '저희 앱은',
      description: ' 사용자의 구독 서비스를 분석하고,',
      emoji: '🧐',
      imagePath: 'assets/images/onboarding_1.png', 
      emojiPosition: EmojiPosition.belowDescription,
    ),
    OnboardingItem(
      mainTitle: '저희 앱은',
      description: ' 사용자의 서비스별 만족도를\n 시각화하여 안내하고,',
      emoji: '🙂',
      imagePath: 'assets/images/onboarding_2.png', 
      emojiPosition: EmojiPosition.bottomRightOfPhone,
    ),
    OnboardingItem(
      mainTitle: '저희 앱은',
      description: ' 해지하였을 때의 비용을\n 계산 해 줍니다',
      emoji: '🤔',
      imagePath: 'assets/images/onboarding_3.png', 
      emojiPosition: EmojiPosition.middleRightOfPhone,
    ),
  ];

  int _currentIndex = 0;
  final CarouselSliderController _controller = CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6), // 밝은 회색 배경
      body: SafeArea(
        child: Column(
          children: [
            // 1. 슬라이더가 차지할 영역
            Expanded(
              child: CarouselSlider.builder(
                carouselController: _controller,
                itemCount: _items.length,
                itemBuilder: (context, index, realIndex) {
                  return _buildOnboardingPage(_items[index]);
                },
                options: CarouselOptions(
                  height: double.infinity, 
                  autoPlay: true, 
                  autoPlayInterval: const Duration(seconds: 4), 
                  viewportFraction: 1.0, 
                  onPageChanged: (index, reason) {
                    setState(() { _currentIndex = index; });
                  },
                ),
              ),
            ),

            // 2. 페이지 인디케이터 (점 3개) - 남색
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _items.asMap().entries.map((entry) {
                return GestureDetector(
                  onTap: () => _controller.animateToPage(
                    entry.key,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.ease,
                  ),
                  child: Container(
                    width: 8.0,
                    height: 8.0,
                    margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 4.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentIndex == entry.key 
                          ? const Color(0xFF1A237E)
                          : const Color(0xFF1A237E).withOpacity(0.3),
                    ),
                  ),
                );
              }).toList(),
            ),

            // 3. 로그인 버튼 - 남색 배경
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A237E), // 남색 배경
                  foregroundColor: Colors.white, // 흰색 글씨
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(100.0),
                  ),
                ),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
                child: const Text('로그인', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            
            // 4. 회원가입 버튼 - 검은색 계열 텍스트
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SignupScreen()),
                );
              },
              child: const Text(
                '계정이 없으시면 여기를 눌러 회원 가입을 해주세요',
                style: TextStyle(color: Colors.black54, fontSize: 12),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // 각 슬라이드 페이지의 UI를 만드는 함수
  Widget _buildOnboardingPage(OnboardingItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 60), 
          
          // 1. 텍스트 블록
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.mainTitle,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A237E),
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                item.description,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  height: 1.4,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 10), // 텍스트/이모지와 폰 이미지 사이 간격

          // 2. 폰 목업 이미지 + 이모지 (동적 배치)
          Expanded(
            child: Center(
              child: Stack(
                clipBehavior: Clip.none, 
                alignment: Alignment.center,
                children: [
                  // 2-1. 폰 목업 이미지 
                  Image.asset(
                    item.imagePath,
                    height: 400, 
                    fit: BoxFit.contain,
                  ),

                  if (item.emojiPosition == EmojiPosition.belowDescription)
                    Positioned(
                      right: -10,
                      top: 100,
                      child: Text(item.emoji, style: const TextStyle(fontSize: 56)),
                    ),

                  if (item.emojiPosition == EmojiPosition.bottomRightOfPhone)
                    Positioned(
                      left: -20,
                      bottom: -30,
                      child: Text(item.emoji, style: const TextStyle(fontSize: 56)),
                    ),

                  if (item.emojiPosition == EmojiPosition.middleRightOfPhone)
                    Positioned(
                      right: -20,
                      top: 190,
                      child: Text(item.emoji, style: const TextStyle(fontSize: 56)),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}