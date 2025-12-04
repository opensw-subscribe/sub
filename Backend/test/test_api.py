import os
import pytest
import requests
from requests.exceptions import ConnectionError

# CI/CD 환경에서는 'BACKEND_URL'
# 로컬 테스트 시에는 'http://localhost:8080' 등을 사용하도록 설정
BASE_URL = os.environ.get('BACKEND_URL', 'http://localhost:8080')

# 테스트를 시작하기 전에 BASE_URL이 유효한지 확인합니다.
@pytest.fixture(scope="session", autouse=True)
def check_base_url():
    """테스트를 실행하기 전에 BASE_URL이 설정되었는지 확인"""
    if not BASE_URL:
        pytest.skip("환경 변수 'BACKEND_URL'이 설정되지 않았습니다. API 테스트를 건너뜁니다.")
    print(f"\nAPI 테스트 기본 URL: {BASE_URL}")

def test_api_connection():
    """API 서버가 활성화되어 연결 가능한지 확인"""
    print(f"테스트 연결 시도: {BASE_URL}/health")
    try:
        # 서버의 상태를 확인하는 헬스 체크 엔드포인트(가정)
        response = requests.get(f"{BASE_URL}/health", timeout=5)
        
        # 200 또는 204와 같은 성공적인 응답 코드를 확인합니다.
        assert response.status_code in [200, 204], \
            f"서버 연결 실패. 응답 코드: {response.status_code}"
            
    except ConnectionError as e:
        pytest.fail(f"백엔드 서버에 연결할 수 없습니다. URL: {BASE_URL}. 에러: {e}")
    except Exception as e:
        pytest.fail(f"예상치 못한 에러 발생: {e}")

def test_get_users_endpoint():
    """/api/users 엔드포인트가 올바르게 작동하고 데이터를 반환하는지 확인"""
    endpoint = "/api/users"
    url = f"{BASE_URL}{endpoint}"
    print(f"테스트 GET 요청: {url}")
    
    response = requests.get(url)
    
    # 1. 상태 코드 확인
    assert response.status_code == 200, \
        f"GET {endpoint} 실패. 응답 코드: {response.status_code}, 응답: {response.text}"
    
    # 2. JSON 형식 확인 (선택 사항)
    try:
        data = response.json()
        assert isinstance(data, list) or isinstance(data, dict), \
            f"응답이 올바른 JSON 형식이 아닙니다. 타입: {type(data)}"
            
    except requests.exceptions.JSONDecodeError:
        pytest.fail(f"응답 본문이 JSON이 아닙니다: {response.text}")