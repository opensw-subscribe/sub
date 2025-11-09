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
        category_name = sub.category.category_name
        alpha = recommend_alpha(category_name)
        mode = default_mode(category_name)

        # FIX 1: Decimal 타입인 sub.service_monthly_price를 float으로 변환하여 서비스 함수에 전달
        monthly_price_float = float(sub.service_monthly_price)
        
        # 계산
        value_score = value_score_log(sub.service_usage_time, sub.service_usage, mode)
        # float으로 변환된 monthly_price_float을 cost_per_use에 전달
        once_cost = cost_per_use(monthly_price_float, sub.service_usage_time, sub.service_usage, alpha) 

        # 결과 조합
        results.append({
            "user_id": db_user.user_id,
            "app_name": sub.app_name,
            "app_category": category_name,
            "service_monthly_price": monthly_price_float, # 결과 반환 시에도 float 사용
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

    # 전체 합계는 float으로 계산
    total = sum(float(sub.service_monthly_price) for sub in subs)
    
    graph_data = [
        {
            "user_id": db_user.user_id,
            "app_name": sub.app_name,
            "service_monthly_price": float(sub.service_monthly_price), # 결과 반환 시에도 float 사용
            # FIX 2: 나눗셈 연산 전에 sub.service_monthly_price를 float으로 변환
            "ratio": round(float(sub.service_monthly_price) / total, 2) if total > 0 else 0
        }
        for sub in subs
    ]
    return {"success": True, "data": graph_data, "message": ""}