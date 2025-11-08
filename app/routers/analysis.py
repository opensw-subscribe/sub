from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import List
from app.db import models, schemas, session
from app.core.firebase import firebase_auth
from app.services.value_calculator import value_score_log, cost_per_use, recommend_alpha, default_mode

router = APIRouter(prefix="/api", tags=["analysis"])

# 의존성: DB 세션
def get_db():
    db = session.SessionLocal()
    try:
        yield db
    finally:
        db.close()

# 통계 및 계산
@router.get("/statistic")
def get_statistics(user=Depends(firebase_auth), db: Session = Depends(get_db)):
    # 사용자 확인
    db_user = db.query(models.User).filter(models.User.firebase_uid == user["uid"]).first()
    if not db_user:
        raise HTTPException(status_code=404, detail="User not found")

    results = []
    for sub in db_user.subscriptions:
        # 알파 값과 모드 결정
        alpha = recommend_alpha(sub.app_category)
        mode = default_mode(sub.app_category)

        # 계산
        value_score = value_score_log(sub.service_usage_time, sub.service_usage, mode)
        once_cost = cost_per_use(sub.service_monthly_price, sub.service_usage_time, sub.service_usage, alpha)

        # 결과 조합
        results.append({
            "user_id": db_user.user_id,
            "app_name": sub.app_name,
            "app_category": sub.app_category,
            "service_monthly_price": sub.service_monthly_price,
            "service_once_price": once_cost,
            "user_satis": sub.user_satis,
            "value_score": value_score
        })

    return {"success": True, "data": results, "message": ""}


# 원형 그래프
@router.get("/circleGraph")
def get_circle_graph(user=Depends(firebase_auth), db: Session = Depends(get_db)):
    db_user = db.query(models.User).filter(models.User.firebase_uid == user["uid"]).first()
    if not db_user:
        raise HTTPException(status_code=404, detail="User not found")

    subs = db_user.subscriptions
    if not subs:
        return {"success": True, "data": [], "message": ""}

    total = sum(sub.service_monthly_price for sub in subs)
    graph_data = [
        {
            "user_id": db_user.user_id,
            "app_name": sub.app_name,
            "service_monthly_price": sub.service_monthly_price,
            "ratio": round(sub.service_monthly_price / total, 2) if total > 0 else 0
        }
        for sub in subs
    ]
    return {"success": True, "data": graph_data, "message": ""}