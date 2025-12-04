from fastapi import APIRouter

router = APIRouter()

@router.get("/health", status_code=200)
def get_health_status():
    """앱이 실행 중인지 확인하는 헬스 체크 엔드포인트"""
    return {"status": "ok"} # 200 OK 상태 코드를 반환합니다.