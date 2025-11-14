from sqlalchemy.orm import Session
from app.db import models, schemas
from app.core.redis import redis_client
from fastapi import HTTPException
import json

# 캐시 만료 시간 (1시간 = 3600초)
CACHE_EXPIRATION = 3600

def get_user_by_uid(db: Session, user_id: str):
    """
    UID를 사용하여 사용자 정보를 Redis에서 조회하고, 없으면 DB에서 조회 후 캐싱합니다.
    """
    redis_key = f"user:{user_id}"

    # 1. Redis 캐시 확인
    if redis_client:
        try:
            cached_user_json = redis_client.get(redis_key)
            if cached_user_json:
                # print(f"Cache Hit for user: {user_id}")
                user_data = json.loads(cached_user_json)
                # Pydantic 스키마를 사용하여 데이터 유효성 검사 및 반환
                return schemas.UserOut(**user_data)
        except Exception as e:
             # Redis 에러 발생 시 (네트워크 등), 캐싱을 무시하고 DB로 넘어감
             print(f"Redis operation error: {e}. Proceeding to DB.")

    # 2. 캐시 미스 또는 Redis 연결/오류 시 DB 조회
    # print(f"Cache Miss for user: {user_id}. Querying DB.")
    db_user = db.query(models.User).filter(models.User.user_id == user_id).first()
    
    if db_user:
        # 3. DB에서 조회된 User 모델을 Pydantic 스키마로 변환
        user_out = schemas.UserOut.from_orm(db_user)
        
        # 4. Redis에 저장
        if redis_client:
            try:
                user_json = user_out.json() # JSON 문자열로 변환
                redis_client.setex(redis_key, CACHE_EXPIRATION, user_json)
                # print(f"Stored user for: {user_id}")
            except Exception as e:
                 print(f"Redis setex error: {e}")
            
        return db_user
        
    return None

def create_user(db: Session, user_id: str, email: str, user_name: str):
    """
    새 사용자를 DB에 생성하고 Redis 캐시를 업데이트합니다.
    """
    # 1. DB에 사용자 생성
    new_user = models.User(
        user_id=user_id,
        email=email,
        user_name=user_name
    )
    db.add(new_user)
    db.commit()
    db.refresh(new_user)

    # 2. Redis 캐시에 저장 (생성 후 즉시 캐싱)
    if redis_client:
        try:
            redis_key = f"user:{user_id}"
            user_out = schemas.UserOut.from_orm(new_user)
            user_json = user_out.json()
            redis_client.setex(redis_key, CACHE_EXPIRATION, user_json)
            # print(f"User created and cached: {user_id}")
        except Exception as e:
            print(f"Redis setex error after creation: {e}")

    return new_user