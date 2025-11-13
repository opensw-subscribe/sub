from fastapi import Depends, FastAPI, Request
from app.core.firebase import firebase_auth
from app.db import models, session
from app.routers import users, subscriptions, analysis
from app.routers.users import router as users_router
import os
import redis

# DB 테이블 생성
models.Base.metadata.create_all(bind=session.engine)

# Redis 연결
REDIS_HOST = os.getenv("REDIS_HOST", "localhost")
REDIS_PORT = int(os.getenv("REDIS_PORT", 6379))
redis_client = redis.Redis(host=REDIS_HOST, port=REDIS_PORT, decode_responses=True)

app = FastAPI(title="Subscription Backend API")

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
