import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;


  final String baseUrl = 'http://10.0.2.2:52141';

  Future<void> signup({
    required String email,
    required String username,
    required String password,
  }) async {
    
    await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final String idToken = await getIdToken();

   
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', idToken);
  }

  
  Future<void> login({
    required String email,
    required String password,
  }) async {
  
    await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    
    final String idToken = await getIdToken();

    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', idToken);
  }

  
  Future<void> createUserOnBackend({
    required String userName,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      throw Exception('토큰 없음');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/api/users/'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'user_name': userName,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('백엔드 사용자 생성 실패');
    }
  }

  // ✅ 4️⃣ 내 정보 조회 (/api/users/me)
  Future<Map<String, dynamic>> getMyInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      throw Exception('저장된 토큰 없음');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/api/users/me'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('유저 정보 조회 실패');
    }

    return jsonDecode(response.body);
  }

  // ✅ 5️⃣ idToken 가져오기
  Future<String> getIdToken() async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('로그인된 유저 없음');
    }

    final String? token = await user.getIdToken();
    if (token == null) {
      throw Exception('토큰 발급 실패');
    }
    return token;
  }

  // ✅ 6️⃣ 로그아웃
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await _auth.signOut();
  }
}
