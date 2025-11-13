import 'package:flutter/material.dart';
import 'package:poc_app_usage/screens/permission_screen.dart';
import 'package:poc_app_usage/widgets/custom_text_field.dart';
// import 'package:poc_app_usage/service/auth_service.dart';
import 'package:poc_app_usage/screens/login_screen.dart';
import 'package:poc_app_usage/service/dummy_auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart'; // 토큰 저장용

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _idController = TextEditingController(); // 아이디로 사용
  final TextEditingController _passwordController = TextEditingController();

  bool _nameError = false;
  bool _idError = false;
  bool _passwordError = false;
  bool _isLoading = false;
  String? _errorMsg;
  
  //final AuthService _authService = AuthService();
  
  // 더미 인증 서비스 사용
  final DummyAuthService _authService = DummyAuthService();

  @override
  void initState() {
    super.initState();
    _authService.addDummyUser(); 
  } // 여기까지 테스트용 더미 유저 등록

  Future<void> _signup() async {
    final String name = _nameController.text.trim();
    final String id = _idController.text.trim();
    final String password = _passwordController.text;

    final bool nameEmpty = name.isEmpty;
    final bool idEmpty = id.isEmpty;
    final bool passwordEmpty = password.isEmpty;
    final bool nameTooLong = name.length > 5; 

    if (nameEmpty || idEmpty || passwordEmpty || nameTooLong) {
      setState(() {
        _nameError = nameEmpty || nameTooLong;
        _idError = idEmpty;
        _passwordError = passwordEmpty;
        _errorMsg = nameTooLong ? '닉네임은 5자 이하여야 합니다.' : null;
      });
      return;
    }

    setState(() { _isLoading = true; _errorMsg = null; });
    try {
      // 회원가입
      await _authService.signup(
        username: name,
        user_id: id,
        password: password,
      );

      // 자동 로그인
      final loginData = await _authService.login(
        user_id: id,
        password: password,
      );

      // 토큰 저장
      final prefs = await SharedPreferences.getInstance();
      if (loginData.containsKey('token')) {
        await prefs.setString('auth_token', loginData['token']);
      }

      // PermissionScreen으로 이동
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PermissionScreen()),
        );
      }
    } catch (e) {
      setState(() { _errorMsg = e.toString(); });
    } finally {
      setState(() { _isLoading = false; });
    }
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
                  child: Text(_errorMsg!, style: const TextStyle(color: Colors.red, fontSize: 13)),
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