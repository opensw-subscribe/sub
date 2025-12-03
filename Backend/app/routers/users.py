from typing import List
from fastapi import APIRouter, HTTPException, Depends
from sqlalchemy.orm import Session

# 기존 import
from app.db import models, schemas, session
from app.core.firebase import firebase_auth
# 새로 추가된 서비스 파일 import
from app.services import users as user_service 

router = APIRouter(prefix="/api/users", tags=["users"])

# DB 세션 의존성 함수는 그대로 유지
def get_db():
    db = session.SessionLocal()
    try:
        yield db
    finally:
        db.close()

# 사용자 생성
@router.post("/", response_model=schemas.UserOut)
def create_user(data: schemas.UserCreate, user=Depends(firebase_auth), db: Session = Depends(get_db)):
    # DB 직접 쿼리 대신 캐싱된 서비스 함수 사용
    db_user = user_service.get_user_by_uid(db, user["uid"])
    
    if db_user:
        raise HTTPException(status_code=409, detail="User already exists")

    # 사용자 생성 및 캐싱 로직이 포함된 서비스 함수 호출
    new_user = user_service.create_user(
        db, 
        user_id=user["uid"], 
        email=user["email"], 
        user_name=data.user_name
    )
    return new_user

# 전체 사용자 조회 (관리자용) - 변경 없음
@router.get("/", response_model=List[schemas.UserOut])
def list_users(db: Session = Depends(get_db)):
    return db.query(models.User).all()

# 본인 정보 조회
@router.get("/me", response_model=schemas.UserOut)
def get_my_info(user=Depends(firebase_auth), db: Session = Depends(get_db)):
    # DB 직접 쿼리 대신 캐싱된 서비스 함수 사용
    db_user = user_service.get_user_by_uid(db, user["uid"])
    
    if not db_user:
        raise HTTPException(status_code=404, detail="User not found")
        
    return db_user