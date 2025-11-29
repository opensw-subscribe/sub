import 'package:flutter/material.dart';
import 'package:poc_app_usage/screens/signup_screen.dart';
import 'package:poc_app_usage/widgets/custom_text_field.dart';
import 'package:poc_app_usage/screens/main_screen.dart';
import 'package:poc_app_usage/service/auth_service.dart';
import 'package:poc_app_usage/service/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/logger.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _idError = false;
  bool _passwordError = false;
  bool _isLoading = false;
  String? _errorMsg;

  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  Future<void> _login() async {
    final String email = _idController.text.trim();
    final String password = _passwordController.text;

    final bool idEmpty = email.isEmpty;
    final bool passwordEmpty = password.isEmpty;

    if (idEmpty || passwordEmpty) {
      setState(() {
        _idError = idEmpty;
        _passwordError = passwordEmpty;
        _errorMsg = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMsg = null;
    });

    try {
      // 1) Firebase 로그인
      await _authService.login(email: email, password: password);

      // 2) idToken 가져오기
      final String idToken = await _authService.getIdToken();

      // 3) 백엔드에 내 정보 조회 요청 (검증 겸)
      final me = await _userService.getMe(idToken: idToken);
      logger.d('내 정보: $me');

      // 4) 토큰 저장
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', idToken);
      await prefs.setString('email', email);

      // 5) 메인 화면으로 이동
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const MainDashboardScreen(),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMsg = '로그인 실패: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _idController.dispose();
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
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignupScreen(),
                            ),
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
                key: ValueKey('id_${_idError.toString()}'),
                controller: _idController,
                hintText: '이메일',
                showError: _idError,
                onChanged: (v) {
                  if (_idError && v.isNotEmpty) {
                    setState(() => _idError = false);
                  }
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                key: ValueKey('pw_${_passwordError.toString()}'),
                controller: _passwordController,
                hintText: '비밀번호',
                isPassword: true,
                showError: _passwordError,
                onChanged: (v) {
                  if (_passwordError && v.isNotEmpty) {
                    setState(() => _passwordError = false);
                  }
                },
              ),
              const SizedBox(height: 32),
              if (_errorMsg != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    _errorMsg!,
                    style: const TextStyle(color: Colors.red, fontSize: 13),
                  ),
                ),
              ElevatedButton(
                onPressed: _isLoading ? null : _login,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('로그인'),
              ),
              const SizedBox(height: 16),
              Center(
                child: TextButton(
                  onPressed: () {
                    logger.d('비밀번호 찾기');
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


//예은 테스트용 임시 코드 - 나중에 지워도 됨

// import 'package:flutter/material.dart';
// import 'package:poc_app_usage/screens/signup_screen.dart';
// import 'package:poc_app_usage/widgets/custom_text_field.dart';
// import 'package:poc_app_usage/screens/choose_platform_screen.dart'; // ✅ 여기를 추가해야 함

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();

//   bool _emailError = false;
//   bool _passwordError = false;

//   void _login() {
//     final String email = _emailController.text.trim();
//     final String password = _passwordController.text;

//     print("로그인 시도: 이메일=$email, 비밀번호=$password");

//     // ✅ 로그인 버튼 클릭 시 choose_platform_screen으로 이동
//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(
//         builder: (context) => const ChoosePlatformScreen(),
//       ),
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
//               const SizedBox(height: 64),
//               SizedBox(
//                 height: 40,
//                 child: Stack(
//                   alignment: Alignment.center,
//                   children: [
//                     const Text(
//                       '로그인',
//                       style: TextStyle(
//                         fontSize: 28,
//                         fontWeight: FontWeight.bold,
//                         color: Colors.black,
//                       ),
//                     ),
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

//               CustomTextField(
//                 controller: _emailController,
//                 hintText: '아이디',
//                 showError: _emailError,
//               ),
//               const SizedBox(height: 16),

//               CustomTextField(
//                 controller: _passwordController,
//                 hintText: '비밀번호',
//                 isPassword: true,
//                 showError: _passwordError,
//               ),
//               const SizedBox(height: 32),

//               ElevatedButton(
//                 onPressed: _login,
//                 child: const Text('로그인'),
//               ),
//               const SizedBox(height: 16),

//               Center(
//                 child: TextButton(
//                   onPressed: () {
//                     print('비밀번호 찾기');
//                   },
//                   child: const Text(
//                     '비밀번호를 잊으셨습니까?',
//                     style: TextStyle(
//                       color: Color(0xFF1A237E),
//                       fontSize: 14,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ),

//               const Spacer(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }