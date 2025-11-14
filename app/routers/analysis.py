from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.db import models, session
from app.core.firebase import firebase_auth
from app.services.value_calculator import value_score_log, cost_per_use, recommend_alpha, default_mode

router = APIRouter(prefix="/api", tags=["analysis"])

def get_db():
    db = session.SessionLocal()
    try:
        yield db
    finally:
        db.close()

@router.get("/statistic")
def get_statistics(user=Depends(firebase_auth), db: Session = Depends(get_db)):
    db_user = db.query(models.User).filter(models.User.user_id == user["uid"]).first()
    if not db_user:
        raise HTTPException(status_code=404, detail="User not found")

    results = []
    for sub in db_user.subscriptions:
        category_name = sub.category.category_name
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
            "value_score": value_score
        })

    return {"success": True, "data": results, "message": ""}

@router.get("/circleGraph")
def get_circle_graph(user=Depends(firebase_auth), db: Session = Depends(get_db)):
    db_user = db.query(models.User).filter(models.User.user_id == user["uid"]).first()
    if not db_user:
        raise HTTPException(status_code=404, detail="User not found")

    subs = db_user.subscriptions
    if not subs:
        return {"success": True, "data": [], "message": ""}

    total = sum(float(sub.service_monthly_price) for sub in subs)
    graph_data = [
        {
            "user_id": db_user.user_id,
            "app_name": sub.app_name,
            "service_monthly_price": float(sub.service_monthly_price),
            "ratio": round(float(sub.service_monthly_price) / total, 2) if total > 0 else 0
        }
        for sub in subs
    ]
    return {"success": True, "data": graph_data, "message": ""}
