from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from sqlalchemy.orm import joinedload
from sqlalchemy import func # sum을 위한 func import
from app.db import models, session
from app.core.firebase import firebase_auth
from app.services.value_calculator import value_score_log, value_score_log_with_satisfaction, cost_per_use, recommend_alpha, default_mode

router = APIRouter(prefix="/api")

def get_db():
    db = session.SessionLocal()
    try:
        yield db
    finally:
        db.close()

# -------------------------
# 월별 구독 통계
# -------------------------
@router.get("/statistic", tags=["analysis"])
def get_statistics(
    month: str = Query(..., description="YYYY-MM 형식"),
    user=Depends(firebase_auth),
    db: Session = Depends(get_db)
):
    db_user = db.query(models.User).filter(models.User.user_id == user["uid"]).first()
    if not db_user:
        raise HTTPException(status_code=404, detail="User not found")

    # 월별 필터링 (month 컬럼 기준)
    subs = [sub for sub in db_user.subscriptions if sub.month == month]

    results = []
    for sub in subs:
        category_name = sub.category.category_name
        # 카테고리에 따른 알파값
        alpha = recommend_alpha(category_name)
        mode = default_mode(category_name)

        monthly_price_float = float(sub.service_monthly_price)
        value_score = value_score_log(sub.service_usage_time, sub.service_usage, mode)
        once_cost = cost_per_use(monthly_price_float, sub.service_usage_time, sub.service_usage, alpha)

        results.append({
            "user_id": db_user.user_id,
            "app_name": sub.app_name,
            "app_category": category_name,
            "service_monthly_price": monthly_price_float,
            "service_once_price": once_cost,
            "user_satis": sub.user_satis,
        })

    return {"success": True, "data": results, "message": ""}


# -------------------------
# 월별 구독 통계 (만족도 포함)
# -------------------------
@router.get("/statistic/rating", tags=["analysis"])
def get_statistics_with_rating(
    month: str = Query(..., description="YYYY-MM 형식"),
    user=Depends(firebase_auth),
    db: Session = Depends(get_db)
):
    db_user = db.query(models.User).filter(models.User.user_id == user["uid"]).options(
        joinedload(models.User.subscriptions).joinedload(models.Subscription.category)
    ).first()
    if not db_user:
        raise HTTPException(status_code=404, detail="User not found")

    # 월별 필터링 (month 컬럼 기준)
    subs = [sub for sub in db_user.subscriptions if sub.month == month]

    results = []
    for sub in subs:
        category_name = sub.category.category_name
        # 카테고리에 따른 알파값
        alpha = recommend_alpha(category_name)
        mode = default_mode(category_name)

        monthly_price_float = float(sub.service_monthly_price)
        # 만족도 포함 가치 점수 계산
        value_score = value_score_log_with_satisfaction(
            sub.service_usage_time, 
            sub.service_usage, 
            mode, 
            sub.user_satis
        )
        once_cost = cost_per_use(monthly_price_float, sub.service_usage_time, sub.service_usage, alpha)
        value_factor = 1 + (value_score / 100)     # 1.0 ~ 2.0
        adjusted_once_cost = once_cost / value_factor
        
        results.append({
            "user_id": db_user.user_id,
            "app_name": sub.app_name,
            "app_category": category_name,
            "service_monthly_price": int(sub.service_monthly_price),
            "service_once_price": int(adjusted_once_cost),
            "user_satis": sub.user_satis,
        })

    return {"success": True, "data": results, "message": ""}


# -------------------------
# 월별 원형 그래프
# -------------------------
@router.get("/circleGraph", tags=["analysis"])
def get_circle_graph(
    month: str = Query(..., description="YYYY-MM 형식"),
    user=Depends(firebase_auth),
    db: Session = Depends(get_db)
):
    
    db_user = db.query(models.User).filter(models.User.user_id == user["uid"]).first()
    if not db_user:
        raise HTTPException(status_code=404, detail="User not found")
    
    subs = db.query(models.Subscription).filter(
        models.Subscription.user_id == user["uid"],
        models.Subscription.month == month
    ).all()

    if not subs:
        return {"success": True, "data": [], "message": "No subscriptions found for the month."}

    graph_data = [
        {
            "user_id": sub.user_id,
            "app_name": sub.app_name,
            "service_monthly_price": int(sub.service_monthly_price),
        }
        for sub in subs
    ]
    return {"success": True, "data": graph_data, "message": ""}

# -------------------------
# 월별 Whatif 데이터 조회
# -------------------------
@router.get("/whatif", tags=["whatif"])
def get_whatif_data(
    month: str = Query(..., description="YYYY-MM 형식"),
    user=Depends(firebase_auth),
    db: Session = Depends(get_db)
):
    
    db_user = db.query(models.User).filter(models.User.user_id == user["uid"]).first()
    if not db_user:
        raise HTTPException(status_code=404, detail="User not found")
    
    subs = db.query(models.Subscription).filter(
        models.Subscription.user_id == user["uid"],
        models.Subscription.month == month
    ).options(
        joinedload(models.Subscription.category) # Category를 미리 로드
    ).all()
    
    if not subs:
        return {"success": True, "data": [], "message": "No subscriptions found."}

    # 3. 데이터 변환
    results = []
    for sub in subs:
        results.append({
            "user_id": sub.user_id, # sub에서 직접 가져오는 것이 깔끔
            "app_name": sub.app_name,
            "app_category": sub.category.category_name, # N+1 없이 즉시 접근 가능
            "service_monthly_price": float(sub.service_monthly_price),
            "isActive": sub.is_active
        })

    return {"success": True, "data": results, "message": ""}