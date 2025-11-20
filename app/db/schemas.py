from pydantic import BaseModel, ConfigDict
from typing import Optional

# User
class UserCreate(BaseModel):
    # email: str
    user_name: str

class UserOut(BaseModel):
    user_id: str
    email: str
    user_name: str

    model_config = ConfigDict(from_attributes=True)

# Category
class CategoryCreate(BaseModel):
    category_name: str

# Subscription
class SubscriptionBase(BaseModel):
    sub_id: int
    app_name: str
    category_id: int
    service_monthly_price: float
    service_once_price: Optional[float] = 0
    service_usage_time: int
    service_usage: int
    weekly_usage_hours: Optional[float] = 0
    user_satis: int
    is_active: Optional[bool] = True

    model_config = ConfigDict(
        from_attributes=True,  # orm_mode 대체
        populate_by_name=True  # alias (id)를 사용할 수 있도록 설정
    )
            
class SubscriptionCreate(BaseModel):
    app_name: str
    category_id: int
    service_monthly_price: float
    service_once_price: Optional[float] = 0
    service_usage_time: int
    service_usage: int
    weekly_usage_hours: Optional[float] = 0
    user_satis: int
    is_active: Optional[bool] = True

    class Config:
        orm_mode = True


class SubscriptionBase(BaseModel):
    sub_id: int
    app_name: str
    category_id: int
    service_monthly_price: float
    service_once_price: Optional[float] = 0
    service_usage_time: int
    service_usage: int
    weekly_usage_hours: Optional[float] = 0
    user_satis: int
    is_active: Optional[bool] = True
    month: str  # YYYY-MM 형식 추가

    model_config = ConfigDict(
        from_attributes=True,
        populate_by_name=True
    )

class SubscriptionOut(SubscriptionBase):
    pass


class SubscriptionOut(SubscriptionBase):
    pass

# Analysis
class AnalysisResultOut(BaseModel):
    result_id: int
    sub_id: int
    calculated_cph: float
    quadrant_type: str

    model_config = ConfigDict(from_attributes=True)

##별점모델
class SubscriptionRatingUpdateRequest(BaseModel):
    user_id: str 
    app_name: str 
    user_satis: int
    month: Optional[str] = None  # 월별로 별점 저장할 경우

