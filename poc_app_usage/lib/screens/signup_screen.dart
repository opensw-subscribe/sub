import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // 파이어베이스 추가
import 'package:poc_app_usage/screens/permission_screen.dart';
import 'package:poc_app_usage/widgets/custom_text_field.dart';
import 'package:poc_app_usage/service/auth_service.dart'; // 진짜 AuthService
import 'package:poc_app_usage/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController(); // id -> email로 변경
  final TextEditingController _passwordController = TextEditingController();

  bool _nameError = false;
  bool _emailError = false; // id -> email
  bool _passwordError = false;
  bool _isLoading = false;
  String? _errorMsg;
  
  // 진짜 인증 서비스 인스턴스 생성
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signup() async {
    final String name = _nameController.text.trim();
    final String email = _emailController.text.trim(); // id -> email
    final String password = _passwordController.text.trim(); // 공백 제거

    final bool nameEmpty = name.isEmpty;
    final bool emailEmpty = email.isEmpty;
    final bool passwordEmpty = password.isEmpty;
    final bool nameTooLong = name.length > 5; 

    // 1. 입력값 검증
    if (nameEmpty || emailEmpty || passwordEmpty || nameTooLong) {
      setState(() {
        _nameError = nameEmpty || nameTooLong;
        _emailError = emailEmpty;
        _passwordError = passwordEmpty;
        _errorMsg = nameTooLong ? '닉네임은 5자 이하여야 합니다.' : '모든 항목을 입력해주세요.';
      });
      return;
    }

    setState(() { _isLoading = true; _errorMsg = null; });

    try {
      // 2. [Firebase] 이메일/비번으로 회원가입 시도
      final UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 3. [Firebase] 생성된 유저의 ID 토큰 가져오기
      final User? user = userCredential.user;
      if (user == null) throw Exception("유저 생성 실패");
      
      final String? token = await user.getIdToken();

      if (token != null) {
        // 4. [Backend] 닉네임과 토큰을 서버로 전송 (유저 정보 저장)
        await _authService.signup(
          username: name,
          idToken: token, 
        );

        // 5. [Local] 토큰 저장 (자동 로그인을 위해)
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        
        // (선택사항) 유저 닉네임도 로컬에 저장하고 싶다면
        await prefs.setString('user_name', name);

        // 6. 화면 이동
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const PermissionScreen()),
          );
        }
      }

    } on FirebaseAuthException catch (e) {
      // 파이어베이스 에러 처리 (이미 있는 이메일, 약한 비번 등)
      String message = '회원가입 실패';
      if (e.code == 'weak-password') {
        message = '비밀번호가 너무 쉽습니다.';
      } else if (e.code == 'email-already-in-use') {
        message = '이미 사용 중인 이메일입니다.';
      } else if (e.code == 'invalid-email') {
        message = '이메일 형식이 잘못되었습니다.';
      }
      setState(() { _errorMsg = message; });
      
    } catch (e) {
      // 백엔드 통신 에러 등 기타 에러
      setState(() { 
        // 에러 메시지가 너무 길면 잘라서 보여주기
        _errorMsg = e.toString().replaceAll("Exception:", "").trim(); 
      });
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
                      '회원가입',
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
                            MaterialPageRoute(builder: (context) => const LoginScreen()),
                          );
                        },
                        child: Text(
                          '로그인',
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
              
              // 닉네임 입력
              CustomTextField(
                key: ValueKey('name_${_nameError.toString()}'),
                controller: _nameController,
                hintText: '닉네임(5자이하)',
                showError: _nameError,
                onChanged: (v) {
                  if (_nameError && v.isNotEmpty && v.length <= 5) {
                    setState(() => _nameError = false);
                  }
                },
              ),
              const SizedBox(height: 16),
              
              // 이메일 입력 (기존 idController -> emailController로 변경)
              CustomTextField(
                key: ValueKey('email_${_emailError.toString()}'),
                controller: _emailController,
                hintText: '이메일', // 힌트 텍스트 확인
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
              
              // 에러 메시지 표시
              if (_errorMsg != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    _errorMsg!, 
                    style: const TextStyle(color: Colors.red, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ),
                
              ElevatedButton(
                onPressed: _isLoading ? null : _signup,
                child: _isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('회원가입'),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}