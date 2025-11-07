import 'package:flutter/material.dart';
import 'package:poc_app_usage/widgets/custom_text_field.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _idController = TextEditingController(); // 아이디로 사용
  final TextEditingController _passwordController = TextEditingController();

  // 입력 에러 표시용 상태
  bool _nameError = false;
  bool _idError = false;
  bool _passwordError = false;

  void _signup() {
    final String name = _nameController.text.trim();
    final String id = _idController.text.trim();
    final String password = _passwordController.text;

    final bool nameEmpty = name.isEmpty;
    final bool idEmpty = id.isEmpty;
    final bool passwordEmpty = password.isEmpty;

    if (nameEmpty || idEmpty || passwordEmpty) {
      setState(() {
        _nameError = nameEmpty;
        _idError = idEmpty;
        _passwordError = passwordEmpty;
      });
      return;
    }

    // =============================
    // [API 명세 예시]
    // POST /api/signup
    // Body(JSON): { "name": string, "id": string, "password": string }
    // Response: { "success": bool, "message": string }
    // =============================

    // [백엔드 연동 예시 - 실제 사용 시 주석 해제]
    // import 'package:http/http.dart' as http;
    // import 'dart:convert';
    //
    // Future<void> signupApi() async {
    //   final response = await http.post(
    //     Uri.parse('https://your-backend.com/api/signup'),
    //     headers: { 'Content-Type': 'application/json' },
    //     body: jsonEncode({
    //       'name': name,
    //       'id': id,
    //       'password': password,
    //     }),
    //   );
    //   if (response.statusCode == 200) {
    //     final data = jsonDecode(response.body);
    //     if (data['success']) {
    //       // 회원가입 성공 처리
    //       Navigator.pop(context);
    //     } else {
    //       // 실패 메시지 처리 (예: setState로 에러 표시)
    //     }
    //   } else {
    //     // 네트워크 오류 처리
    //   }
    // }
    //
    // signupApi();

    print("회원가입 시도: 이름=$name, 아이디=$id, 비밀번호=$password");
    // 임시로 회원가입 성공 처리
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _nameController.dispose();
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
                key: ValueKey('id_${_idError.toString()}'),
                controller: _idController,
                hintText: '아이디',
                showError: _idError,
                onChanged: (v) {
                  if (_idError && v.isNotEmpty) {
                    setState(() => _idError = false);
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