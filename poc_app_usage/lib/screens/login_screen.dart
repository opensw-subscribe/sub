import 'package:flutter/material.dart';
import 'package:poc_app_usage/screens/signup_screen.dart';
import 'package:poc_app_usage/widgets/custom_text_field.dart';
import 'package:poc_app_usage/screens/main_screen.dart';
import 'package:poc_app_usage/service/auth_service.dart';
// import 'package:poc_app_usage/service/dummy_auth_service.dart';

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
  
  // 더미 인증 서비스 사용
  // final DummyAuthService _authService = DummyAuthService();

  // @override
  // void initState() {
  //   super.initState();
  //   _authService.addDummyUser(); 
  // } // 여기 까지 테스트용 더미 유저 등록

  Future<void> _login() async {
    final String id = _idController.text.trim();
    final String password = _passwordController.text;

    final bool idEmpty = id.isEmpty;
    final bool passwordEmpty = password.isEmpty;

    if (idEmpty || passwordEmpty) {
      setState(() {
        _idError = idEmpty;
        _passwordError = passwordEmpty;
        _errorMsg = null;
      });
      return;
    }

    setState(() { _isLoading = true; _errorMsg = null; });
    try {
      final result = await _authService.login(user_id: id, password: password);
      if (result['success'] == true) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainDashboardScreen()),
        );
      } else {
        setState(() { _errorMsg = result['message'] ?? '로그인 실패'; });
      }
    } catch (e) {
      setState(() { _errorMsg = e.toString(); });
    } finally {
      setState(() { _isLoading = false; });
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
                onPressed: _isLoading ? null : _login,
                child: _isLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('로그인'),
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