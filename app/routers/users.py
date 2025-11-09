from typing import List
from fastapi import APIRouter, HTTPException, Depends
from sqlalchemy.orm import Session
from app.db import models, schemas, session
from app.core.firebase import firebase_auth

router = APIRouter(prefix="/api/users", tags=["users"])

# 의존성: DB 세션
def get_db():
    db = session.SessionLocal()
    try:
        yield db
    finally:
        db.close()

# 사용자 생성 (Firebase UID 기반)
@router.post("/", response_model=schemas.UserOut)
def create_user(data: schemas.UserCreate, user=Depends(firebase_auth), db: Session = Depends(get_db)):
    db_user = db.query(models.User).filter(models.User.firebase_uid == user["uid"]).first()
    if db_user:
        raise HTTPException(status_code=409, detail="User already exists")

    new_user = models.User(
        firebase_uid=user["uid"],
        user_id=user["uid"],
        email=user["email"],
        user_name=data.user_name
    )
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    return new_user

# 전체 사용자 조회 (관리자용)
@router.get("/", response_model=List[schemas.UserOut])
def list_users(db: Session = Depends(get_db)):
    return db.query(models.User).all()

# 본인 정보 조회
@router.get("/me", response_model=schemas.UserOut)
def get_my_info(user=Depends(firebase_auth), db: Session = Depends(get_db)):
    db_user = db.query(models.User).filter(models.User.firebase_uid == user["uid"]).first()
    if not db_user:
        raise HTTPException(status_code=404, detail="User not found")
    return db_user