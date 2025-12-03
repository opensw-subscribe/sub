import 'dart:async';

class DummyAuthService {
  // 메모리 기반 회원정보 저장소
  final Map<String, Map<String, String>> _users = {}; 
  // 예: _users['test@test.com'] = {'username': '테스트', 'password': '1234'}

  // 회원가입
  Future<Map<String, dynamic>> signup({
    required String user_id,
    required String username,
    required String password,
  }) async {
    await Future.delayed(const Duration(seconds: 1)); // API 지연 흉내

    if (_users.containsKey(user_id)) {
      return {
        'success': false,
        'message': '이미 존재하는 아이디입니다.',
      };
    }

    _users[user_id] = {
      'username': username,
      'password': password,
    };

    return {
      'success': true,
      'message': '회원가입 성공',
      'data': {
        'user_id': user_id,
        'user_name': username,
        'token': 'dummy_jwt_token',
      },
    };
  }

  // 로그인
  Future<Map<String, dynamic>> login({
    required String user_id,
    required String password,
  }) async {
    await Future.delayed(const Duration(seconds: 1));

    if (!_users.containsKey(user_id)) {
      return {
        'success': false,
        'message': '아이디가 존재하지 않습니다.',
      };
    }

    if (_users[user_id]!['password'] != password) {
      return {
        'success': false,
        'message': '비밀번호가 일치하지 않습니다.',
      };
    }

    return {
      'success': true,
      'message': '로그인 성공',
      'data': {
        'user_id': user_id,
        'user_name': _users[user_id]!['username'],
        'token': 'dummy_jwt_token',
      },
    };
  }

  // 테스트용 미리 등록된 회원
  void addDummyUser() {
    _users['test@test.com'] = {'username': '테스터', 'password': '1234'};
    _users['user1@test.com'] = {'username': '유저1', 'password': 'abcd'};
  }
}