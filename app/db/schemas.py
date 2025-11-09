from pydantic import BaseModel
from typing import Optional

# User
class UserCreate(BaseModel):
    email: str
    user_name: str

class UserOut(BaseModel):
    user_id: str
    email: str
    user_name: str

    class Config:
        orm_mode = True

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

    class Config:
            orm_mode = True
            fields = {"sub_id": "id"}
            
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

class SubscriptionOut(SubscriptionBase):
    sub_id: int

    class Config:
        from_attributes = True  # V2에서는 orm_mode 대신 from_attributes 사용

# Analysis
class AnalysisResultOut(BaseModel):
    result_id: int
    sub_id: int
    calculated_cph: float
    quadrant_type: str

    class Config:
        from_attributes = True
