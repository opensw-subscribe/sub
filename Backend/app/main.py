# Backend/main.py (전체)

from fastapi import Depends, FastAPI, Request
from app.core.firebase import firebase_auth
from app.db import models, session
from app.routers import users, subscriptions, health, analysis
from app.routers.users import router as users_router
import os
import redis
import logging
import time

# 로깅 설정
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# DB 테이블 생성
models.Base.metadata.create_all(bind=session.engine)

# ✨ 수정된 init_db_data
def init_db_data():
    """초기 데이터 삽입 (재시도 포함)"""
    max_retries = 10
    retry_delay = 5
    
    for attempt in range(max_retries):
        try:
            print(f"🔄 [INIT] DB 연결 시도 ({attempt + 1}/{max_retries})")
            db = session.SessionLocal()
            
            existing_count = db.query(models.Category).count()
            print(f"📊 [INIT] 현재 categories 테이블에 {existing_count}개의 데이터가 있습니다.")
            
            required_categories = ['OTT', 'Music', 'Contents', 'AI', 'LifeStyle']
            inserted_count = 0
            skipped_count = 0
            
            for cat_name in required_categories:
                existing = db.query(models.Category).filter(models.Category.category_name == cat_name).first()
                if not existing:
                    db.add(models.Category(category_name=cat_name))
                    inserted_count += 1
                    print(f"  ➕ [INIT] 카테고리 추가: {cat_name}")
                else:
                    skipped_count += 1
            
            if inserted_count > 0:
                db.commit()
                print(f"✅ [INIT] 초기 카테고리 데이터 삽입 완료")
            else:
                print(f"✅ [INIT] 모든 초기 카테고리 데이터가 이미 존재합니다.")
            
            db.close()
            return  # 성공
            
        except Exception as e:
            print(f"⚠️ [INIT] DB 연결 실패 ({attempt + 1}/{max_retries}): {e}")
            
            if attempt < max_retries - 1:
                print(f"⏳ {retry_delay}초 후 재시도...")
                time.sleep(retry_delay)
            else:
                print(f"⚠️ [INIT] DB 초기화 실패 - 앱은 계속 실행됩니다")
                return  # 실패해도 앱 시작

# Redis 연결
REDIS_HOST = os.getenv("REDIS_HOST", "localhost")
REDIS_PORT = int(os.getenv("REDIS_PORT", 6379))
redis_client = redis.Redis(host=REDIS_HOST, port=REDIS_PORT, decode_responses=True)

app = FastAPI(title="Subscription Backend API")

# ✨ 수정된 startup_event
@app.on_event("startup")
async def startup_event():
    print("=" * 50)
    print("🚀 [STARTUP] 애플리케이션 시작")
    print("=" * 50)
    try:
        init_db_data()
        print("✅ [STARTUP] 초기화 완료")
    except Exception as e:
        print(f"⚠️ [STARTUP] 초기화 실패: {e}")
        # raise 제거 - 앱은 계속 실행

@app.get("/test")
async def test(request: Request, token=Depends(firebase_auth)):
    return {"message": "Firebase 인증 성공", "uid": request.state.user_id}

@app.get("/redis-test")
def redis_test():
    redis_client.set("test_key", "Hello Redis!")
    value = redis_client.get("test_key")
    return {"redis_value": value}

app.include_router(users.router)
app.include_router(subscriptions.router)
app.include_router(analysis.router)
app.include_router(health.router)

@app.get("/")
def root():
    return {"message": "🚀 Backend API is running!"}
