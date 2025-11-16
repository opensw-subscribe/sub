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


class SubscriptionUpdate(BaseModel):
    app_name: Optional[str] = None
    category_id: Optional[int] = None
    service_monthly_price: Optional[float] = None
    service_once_price: Optional[float] = None
    service_usage_time: Optional[int] = None
    service_usage: Optional[int] = None
    weekly_usage_hours: Optional[float] = None
    user_satis: Optional[int] = None
    is_active: Optional[bool] = None

    model_config = ConfigDict(from_attributes=True)

class SubscriptionOut(SubscriptionBase):
    pass

# Analysis
class AnalysisResultOut(BaseModel):
    result_id: int
    sub_id: int
    calculated_cph: float
    quadrant_type: str

    model_config = ConfigDict(from_attributes=True)

## 별점 모델
class SubscriptionRatingUpdateRequest(BaseModel):
    user_id: str 
    app_name: str 
    user_statis: int
