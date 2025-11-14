from fastapi import APIRouter, HTTPException, Depends
from sqlalchemy.orm import Session
from sqlalchemy import func
from typing import List
from app.db import models, schemas, session
from app.core.firebase import firebase_auth

router = APIRouter(prefix="/api/subscriptions", tags=["subscriptions"])

# 구독 생성
@router.post("/", response_model=schemas.SubscriptionOut)
def create_subscription(sub: schemas.SubscriptionCreate, user=Depends(firebase_auth), db: Session = Depends(session.get_db)):
    # 카테고리 존재 확인
    category = db.query(models.Category).filter(models.Category.category_id == sub.category_id).first()
    if not category:
        raise HTTPException(status_code=404, detail="Category not found")

    # Firebase UID로 사용자 확인
    db_user = db.query(models.User).filter(models.User.firebase_uid == user["uid"]).first()
    if not db_user:
        raise HTTPException(status_code=404, detail="User not found")

    # Subscription 생성
    db_sub = models.Subscription(**sub.dict(), user_id=db_user.user_id)
    db.add(db_sub)
    db.commit()
    db.refresh(db_sub)
    return db_sub

# 본인 구독 전체 조회
@router.get("/", response_model=List[schemas.SubscriptionOut])
def list_subscriptions(user=Depends(firebase_auth), db: Session = Depends(session.get_db)):
    db_user = db.query(models.User).filter(models.User.firebase_uid == user["uid"]).first()
    if not db_user:
        raise HTTPException(status_code=404, detail="User not found")

    return db_user.subscriptions # 본인 구독만 반환

# 월별 구독 조회
@router.get("/monthly", response_model=List[schemas.SubscriptionOut])
def get_monthly_subscriptions(
    year: int,
    month: int,
    user=Depends(firebase_auth),
    db: Session = Depends(session.get_db)
):
    # 사용자 확인
    db_user = db.query(models.User).filter(models.User.firebase_uid == user["uid"]).first()
    if not db_user:
        raise HTTPException(status_code=404, detail="User not found")

    # YYYY-MM 문자열 구성
    month_str = f"{year}-{month:02d}"

    # 본인 구독 중에서 월별 created_at 필터링
    subs = (
        db.query(models.Subscription)
        .filter(
            models.Subscription.user_id == db_user.user_id,
            func.to_char(models.Subscription.created_at, 'YYYY-MM') == month_str
        )
        .all()
    )

    return subs

# 특정 구독 조회
@router.get("/{sub_id}", response_model=schemas.SubscriptionOut)
def get_subscription(sub_id: int, user=Depends(firebase_auth), db: Session = Depends(session.get_db)):
    db_sub = db.query(models.Subscription).filter(models.Subscription.sub_id == sub_id).first()
    if not db_sub or db_sub.user.firebase_uid != user["uid"]:
        raise HTTPException(status_code=404, detail="Subscription not found")
    return db_sub

# 구독 수정
@router.put("/{sub_id}", response_model=schemas.SubscriptionOut)
def update_subscription(sub_id: int, sub_update: schemas.SubscriptionUpdate, user=Depends(firebase_auth), db: Session = Depends(session.get_db)):
    db_sub = db.query(models.Subscription).filter(models.Subscription.sub_id == sub_id).first()
    if not db_sub or db_sub.user.firebase_uid != user["uid"]:
        raise HTTPException(status_code=404, detail="Subscription not found")
    
    for key, value in sub_update.dict(exclude_unset=True).items():
        setattr(db_sub, key, value)
    
    db.commit()
    db.refresh(db_sub)
    return db_sub

# 구독 삭제
@router.delete("/{sub_id}", response_model=dict)
def delete_subscription(sub_id: int, user=Depends(firebase_auth), db: Session = Depends(session.get_db)):
    db_sub = db.query(models.Subscription).filter(models.Subscription.sub_id == sub_id).first()
    if not db_sub or db_sub.user.firebase_uid != user["uid"]:
        raise HTTPException(status_code=404, detail="Subscription not found")
    
    db.delete(db_sub)
    db.commit()
    return {"success": True, "message": f"Subscription {sub_id} deleted"}