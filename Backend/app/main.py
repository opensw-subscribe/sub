from fastapi import Depends, FastAPI, Request
from app.core.firebase import firebase_auth
from app.db import models, session
from app.routers import users, subscriptions, analysis
from app.routers.users import router as users_router
import os
import redis
import logging

# 로깅 설정
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# DB 테이블 생성 (테이블이 없으면 생성, 있으면 유지 - 기존 데이터 보존)
models.Base.metadata.create_all(bind=session.engine)

# 초기 데이터 삽입 (카테고리 데이터)
def init_db_data():
    """
    애플리케이션 시작 시 초기 데이터 삽입
    - categories 테이블에 데이터가 있는지 확인
    - 없으면 초기 카테고리 데이터 삽입
    - 있으면 기존 데이터 유지
    """
    db = session.SessionLocal()
    try:
        # 1. categories 테이블 존재 여부 확인
        try:
            existing_count = db.query(models.Category).count()
            print(f"📊 [INIT] 현재 categories 테이블에 {existing_count}개의 데이터가 있습니다.")
            logger.info(f"📊 현재 categories 테이블에 {existing_count}개의 데이터가 있습니다.")
        except Exception as e:
            print(f"⚠️ [INIT] categories 테이블 조회 중 오류: {e}")
            logger.warning(f"⚠️ categories 테이블 조회 중 오류: {e}")
            existing_count = 0
        
        # 2. 초기 카테고리 데이터 정의
        required_categories = ['OTT', 'Music', 'Contents', 'AI', 'LifeStyle']
        
        # 3. 필요한 카테고리 데이터 확인 및 삽입
        inserted_count = 0
        skipped_count = 0
        
        for cat_name in required_categories:
            existing = db.query(models.Category).filter(models.Category.category_name == cat_name).first()
            if not existing:
                db.add(models.Category(category_name=cat_name))
                inserted_count += 1
                print(f"  ➕ [INIT] 카테고리 추가: {cat_name}")
                logger.info(f"  ➕ 카테고리 추가: {cat_name}")
            else:
                skipped_count += 1
                logger.debug(f"  ✓ 카테고리 이미 존재: {cat_name}")
        
        # 4. 변경사항 커밋
        if inserted_count > 0:
            db.commit()
            print(f"✅ [INIT] 초기 카테고리 데이터 삽입 완료: {inserted_count}개 추가, {skipped_count}개 건너뜀")
            logger.info(f"✅ 초기 카테고리 데이터 삽입 완료: {inserted_count}개 추가, {skipped_count}개 건너뜀")
        else:
            print(f"✅ [INIT] 모든 초기 카테고리 데이터가 이미 존재합니다. (총 {existing_count}개)")
            logger.info(f"✅ 모든 초기 카테고리 데이터가 이미 존재합니다. (총 {existing_count}개)")
            
    except Exception as e:
        print(f"❌ [INIT] 초기 데이터 삽입 중 오류 발생: {e}")
        logger.error(f"❌ 초기 데이터 삽입 중 오류 발생: {e}", exc_info=True)
        db.rollback()
        raise  # 애플리케이션 시작 실패로 처리
    finally:
        db.close()

# Redis 연결
REDIS_HOST = os.getenv("REDIS_HOST", "localhost")
REDIS_PORT = int(os.getenv("REDIS_PORT", 6379))
redis_client = redis.Redis(host=REDIS_HOST, port=REDIS_PORT, decode_responses=True)

app = FastAPI(title="Subscription Backend API")

@app.on_event("startup")
async def startup_event():
    """
    애플리케이션 시작 시 실행되는 이벤트 핸들러
    - DB 초기 데이터 삽입
    - 애플리케이션이 재시작될 때마다 실행됨
    """
    print("=" * 50)
    print("🚀 [STARTUP] 애플리케이션 시작 이벤트 실행됨")
    print("=" * 50)
    logger.info("🚀 애플리케이션 시작 중...")
    try:
        init_db_data()
        print("✅ [STARTUP] 초기화 완료")
        logger.info("✅ 애플리케이션 시작 완료")
    except Exception as e:
        print(f"❌ [STARTUP] 초기화 실패: {e}")
        logger.error(f"❌ 애플리케이션 시작 실패: {e}")
        raise

@app.get("/test")
async def test(request: Request, token=Depends(firebase_auth)):
    return {"message": "Firebase 인증 성공", "uid": request.state.user_id}

@app.get("/redis-test")
def redis_test():
    # Redis에 키/값 저장 후 읽기 테스트
    redis_client.set("test_key", "Hello Redis!")
    value = redis_client.get("test_key")
    return {"redis_value": value}

app.include_router(users.router)
app.include_router(subscriptions.router)
app.include_router(analysis.router)

@app.get("/")
def root():
    return {"message": "🚀 Backend API is running!"}
