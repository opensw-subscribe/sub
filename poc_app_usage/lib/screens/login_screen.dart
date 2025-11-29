import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 파이어베이스 추가
import 'package:shared_preferences/shared_preferences.dart'; // 토큰 저장용
import 'package:poc_app_usage/screens/signup_screen.dart';
import 'package:poc_app_usage/widgets/custom_text_field.dart';
import 'package:poc_app_usage/screens/main_screen.dart'; // 로그인 성공 시 이동할 화면
// import '../utils/logger.dart'; // 로거가 있다면 주석 해제

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // 아이디(이메일)와 비번 컨트롤러
  final TextEditingController _emailController = TextEditingController(); 
  final TextEditingController _passwordController = TextEditingController();

  bool _emailError = false;
  bool _passwordError = false;
  bool _isLoading = false;
  String? _errorMsg;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // 로그인 함수
  Future<void> _login() async {
    final String email = _emailController.text.trim();
    final String password = _passwordController.text.trim();

    final bool emailEmpty = email.isEmpty;
    final bool passwordEmpty = password.isEmpty;

    // 1. 입력값 빈칸 검사
    if (emailEmpty || passwordEmpty) {
      setState(() {
        _emailError = emailEmpty;
        _passwordError = passwordEmpty;
        _errorMsg = '이메일과 비밀번호를 입력해주세요.';
      });
      return;
    }

    setState(() { _isLoading = true; _errorMsg = null; });

    try {
      // 2. [Firebase] 로그인 시도 (백엔드 아님! 파이어베이스가 처리함)
      final UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 3. 로그인 성공 후 토큰 저장 (자동 로그인 및 백엔드 통신용)
      final User? user = userCredential.user;
      if (user != null) {
        final String? token = await user.getIdToken();
        
        if (token != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('auth_token', token);
        }

        // 4. 메인 화면으로 이동
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainDashboardScreen()),
          );
        }
      }

    } on FirebaseAuthException catch (e) {
      // 파이어베이스 에러 메시지 처리 (한국어로 변환)
      String message = '로그인 실패';
      if (e.code == 'user-not-found' || e.code == 'invalid-email') {
        message = '존재하지 않는 계정입니다.';
      } else if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        message = '비밀번호가 틀렸습니다.';
      } else {
        message = '로그인 오류: ${e.message}';
      }
      setState(() { _errorMsg = message; });

    } catch (e) {
      // 기타 에러
      setState(() { _errorMsg = '알 수 없는 오류가 발생했습니다.'; });
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
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
                          // 회원가입 화면으로 이동
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const SignupScreen()),
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
              
              // 이메일 입력
              CustomTextField(
                key: ValueKey('email_${_emailError.toString()}'),
                controller: _emailController,
                hintText: '이메일',
                showError: _emailError,
                onChanged: (v) {
                  if (_emailError && v.isNotEmpty) {
                    setState(() => _emailError = false);
                  }
                },
              ),
              const SizedBox(height: 16),
              
              // 비밀번호 입력
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
              
              // 에러 메시지
              if (_errorMsg != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    _errorMsg!, 
                    style: const TextStyle(color: Colors.red, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ),
                
              // 로그인 버튼
              ElevatedButton(
                onPressed: _isLoading ? null : _login,
                child: _isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('로그인'),
              ),
              const SizedBox(height: 16),
              
              // 비밀번호 찾기 (기능은 나중에 구현)
              Center(
                child: TextButton(
                  onPressed: () {
                     // 나중에 FirebaseAuth.instance.sendPasswordResetEmail(email: ...) 쓰면 됨
                     ScaffoldMessenger.of(context).showSnackBar(
                       const SnackBar(content: Text('준비 중인 기능입니다.')),
                     );
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