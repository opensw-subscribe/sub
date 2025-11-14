import redis
import os
from dotenv import load_dotenv

# .env 파일 로드 (개발 환경에서만 필요하며, Docker 환경에서는 
# docker-compose.yml에 의해 환경 변수가 주입됩니다.)
# load_dotenv()

# 환경 변수에서 호스트와 포트를 가져옵니다.
REDIS_HOST = os.getenv("REDIS_HOST", "redis")
REDIS_PORT = int(os.getenv("REDIS_PORT", 6379))

# REDIS_DB 환경 변수를 추가로 읽어옵니다.
REDIS_DB = int(os.getenv("REDIS_DB", 0))

# Redis 클라이언트 인스턴스 초기화
redis_client = None

try:
    redis_client = redis.Redis(host=REDIS_HOST, port=REDIS_PORT, db=REDIS_DB, decode_responses=True)
    redis_client.ping()
    print("Redis connection successful!")
except redis.exceptions.ConnectionError as e:
    print(f"Redis connection failed: {e}. Running without caching.")
    # Redis 연결 실패 시 None으로 설정하여 캐싱 로직에서 처리 가능하도록 함