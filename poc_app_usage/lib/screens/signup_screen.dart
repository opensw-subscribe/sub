import 'package:flutter/material.dart';
import 'package:poc_app_usage/widgets/custom_text_field.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController(); // 아이디로 사용
  final TextEditingController _passwordController = TextEditingController();

  // 입력 에러 표시용 상태
  bool _nameError = false;
  bool _emailError = false;
  bool _passwordError = false;

  void _signup() {
    final String name = _nameController.text.trim();
    final String email = _emailController.text.trim();
    final String password = _passwordController.text;

    final bool nameEmpty = name.isEmpty;
    final bool emailEmpty = email.isEmpty;
    final bool passwordEmpty = password.isEmpty;

    if (nameEmpty || emailEmpty || passwordEmpty) {
      setState(() {
        _nameError = nameEmpty;
        _emailError = emailEmpty;
        _passwordError = passwordEmpty;
      });
      return;
    }

    print("회원가입 시도: 이름=$name, 이메일=$email, 비밀번호=$password");
    // [!] 여기에 백엔드 API 호출 로직이 들어갑니다. (나중에 구현)

    // (가짜) 회원가입 성공 시 로그인 화면으로 되돌아가기
    // 실제 앱에서는 API 호출 결과에 따라 이동합니다.
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _nameController.dispose();
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
            // 자식 위젯들을 가로로 꽉 채우도록 변경
            crossAxisAlignment: CrossAxisAlignment.stretch, 
            children: [
              // 상단 여백
              const SizedBox(height: 64), 
              
              // 회원가입 제목과 로그인 버튼 (중앙 정렬된 회원가입, 오른쪽에 로그인)
              SizedBox(
                height: 40, // Stack의 높이 지정
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // 중앙에 "회원가입" 제목
                    const Text(
                      '회원가입',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    // 오른쪽에 "로그인" 버튼
                    Positioned(
                      right: 0,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context); // 로그인 화면으로 돌아가기
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

              // 이름 입력창
              CustomTextField(
                key: ValueKey('name_${_nameError.toString()}'),
                controller: _nameController,
                hintText: '이름',
                showError: _nameError,
                onChanged: (v) {
                  if (_nameError && v.isNotEmpty) {
                    setState(() => _nameError = false);
                  }
                },
              ),
              const SizedBox(height: 16),

              // 아이디 입력창
              CustomTextField(
                key: ValueKey('email_${_emailError.toString()}'),
                controller: _emailController,
                hintText: '아이디',
                showError: _emailError,
                onChanged: (v) {
                  if (_emailError && v.isNotEmpty) {
                    setState(() => _emailError = false);
                  }
                },
              ),
              const SizedBox(height: 16),

              // 비밀번호 입력창
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

              // 회원가입 버튼
              ElevatedButton(
                onPressed: _signup,
                child: const Text('회원가입'),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}