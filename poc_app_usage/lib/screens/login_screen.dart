// import 'package:flutter/material.dart';
// import 'package:poc_app_usage/screens/signup_screen.dart';
// import 'package:poc_app_usage/widgets/custom_text_field.dart';
// import 'package:poc_app_usage/screens/main_screen.dart'; // (나중에 만들 메인 대시보드 화면)

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   // 사용자가 입력한 값을 가져올 컨트롤러
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();

//   // 입력 에러 표시용 상태
//   bool _emailError = false;
//   bool _passwordError = false;

//   void _login() {
//     final String email = _emailController.text.trim();
//     final String password = _passwordController.text;

//     // 하나라도 비어있을 때는 팝업 대신 입력창에 에러 효과 표시
//     final bool emailEmpty = email.isEmpty;
//     final bool passwordEmpty = password.isEmpty;

//     if (emailEmpty || passwordEmpty) {
//       setState(() {
//         _emailError = emailEmpty;
//         _passwordError = passwordEmpty;
//       });
//       return;
//     }

//     print("로그인 시도: 이메일=$email, 비밀번호=$password");
//     // 실제 앱에서는 API 호출 결과에 따라 이동합니다.
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (context) => const MainDashboardScreen()),
//     );
//   }

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 24.0),
//           child: Column(
  
//             crossAxisAlignment: CrossAxisAlignment.stretch, 
//             children: [
//               // 상단 여백
//               const SizedBox(height: 64), 
              
//               SizedBox(
//                 height: 40, // Stack의 높이 지정
//                 child: Stack(
//                   alignment: Alignment.center,
//                   children: [
//                     // 중앙에 "로그인" 제목
//                     const Text(
//                       '로그인',
//                       style: TextStyle(
//                         fontSize: 28,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black,
//                       ),
//                     ),
//                     // 오른쪽에 "회원가입" 버튼
//                     Positioned(
//                       right: 0,
//                       child: TextButton(
//                         onPressed: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(builder: (context) => const SignupScreen()),
//                           );
//                         },
//                         child: Text(
//                           '회원가입',
//                           style: TextStyle(
//                             color: Theme.of(context).primaryColor,
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 32),

//               // 아이디 (이메일) 입력창
//               CustomTextField(
//                 key: ValueKey('email_${_emailError.toString()}'),
//                 controller: _emailController,
//                 hintText: '아이디',
//                 showError: _emailError,
//                 onChanged: (v) {
//                   if (_emailError && v.isNotEmpty) {
//                     setState(() => _emailError = false);
//                   }
//                 },
//               ),
//               const SizedBox(height: 16),

//               // 비밀번호 입력창
//               CustomTextField(
//                 key: ValueKey('pw_${_passwordError.toString()}'),
//                 controller: _passwordController,
//                 hintText: '비밀번호',
//                 isPassword: true,
//                 showError: _passwordError,
//                 onChanged: (v) {
//                   if (_passwordError && v.isNotEmpty) {
//                     setState(() => _passwordError = false);
//                   }
//                 },
//               ),
//               const SizedBox(height: 32),

//               // [수정] 로그인 버튼
//               ElevatedButton(
//                 onPressed: _login,
//                 // [!] Expanded나 SizedBox 없이 stretch가 적용되도록 Column에 crossAxisAlignment: CrossAxisAlignment.stretch 추가
//                 child: const Text('로그인'),
//               ),
//               const SizedBox(height: 16),

//               // 비밀번호를 잊으셨습니까? (중앙 정렬)
//               Center(
//                 child: TextButton(
//                   onPressed: () {
//                     print('비밀번호 찾기');
//                     // 비밀번호 찾기 화면으로 이동 (나중에 구현)
//                   },
//                   child: const Text(
//                     '비밀번호를 잊으셨습니까?',
//                     style: TextStyle(
//                       color: Color(0xFF1A237E), // 남색
//                       fontSize: 14,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ),

//               const Spacer(), // 남은 공간을 채워서 위젯들을 상단으로 밀어 올림
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


// ✅ 예은 페이지 테스트용 임시 코드

import 'package:flutter/material.dart';
import 'package:poc_app_usage/screens/signup_screen.dart';
import 'package:poc_app_usage/widgets/custom_text_field.dart';
import 'package:poc_app_usage/screens/choose_platform_screen.dart'; 
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _emailError = false;
  bool _passwordError = false;

  void _login() {
    // ✅ 임시 이동 코드
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SubscriptionScreen()),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 64),
              SizedBox(
                height: 40,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Text(
                      '로그인',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Positioned(
                      right: 0,
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SignupScreen()),
                          );
                        },
                        child: Text(
                          '회원가입',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              CustomTextField(
                controller: _emailController,
                hintText: '아이디',
                showError: _emailError,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _passwordController,
                hintText: '비밀번호',
                isPassword: true,
                showError: _passwordError,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _login, // ✅ 로그인 버튼 → 바로 이동
                child: const Text('로그인'),
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () {
                    print('비밀번호 찾기');
                  },
                  child: const Text(
                    '비밀번호를 잊으셨습니까?',
                    style: TextStyle(
                      color: Color(0xFF1A237E),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
