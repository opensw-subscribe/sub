from pydantic import BaseModel, ConfigDict, Field, field_validator
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
    user_satis: int = Field(..., ge=1, le=5, description="만족도 (1~5)")
    is_active: Optional[bool] = True
    month: str  # YYYY-MM 형식 추가
    
    @field_validator('user_satis')
    @classmethod
    def validate_user_satis(cls, v: int) -> int:
        if not (1 <= v <= 5):
            raise ValueError('user_satis는 1~5 사이의 정수여야 합니다.')
        return v

    model_config = ConfigDict(
        from_attributes=True,
        populate_by_name=True
    )
    # NOTE: ConfigDict 사용 시 아래 class Config는 Pydantic V2에서 사용되지 않으므로 제거하거나 주석 처리해야 합니다.

class SubscriptionCreate(BaseModel):
    app_name: str
    category_id: int
    service_monthly_price: float
    service_once_price: Optional[float] = 0
    service_usage_time: int
    service_usage: int
    weekly_usage_hours: Optional[float] = 0
    user_satis: int = Field(..., ge=1, le=5, description="만족도 (1~5)")
    is_active: Optional[bool] = True
    
    @field_validator('user_satis')
    @classmethod
    def validate_user_satis(cls, v: int) -> int:
        if not (1 <= v <= 5):
            raise ValueError('user_satis는 1~5 사이의 정수여야 합니다.')
        return v

    # NOTE: Pydantic V2 사용 시 model_config = ConfigDict(from_attributes=True)로 대체
    class Config:
        orm_mode = True

class SubscriptionUpdate(BaseModel):
    # 업데이트할 수 있는 필드만 Optional로 정의
    app_name: Optional[str] = None
    category_id: Optional[int] = None
    service_monthly_price: Optional[float] = None
    service_once_price: Optional[float] = None
    service_usage_time: Optional[int] = None
    service_usage: Optional[int] = None
    weekly_usage_hours: Optional[float] = None
    user_satis: Optional[int] = Field(None, ge=1, le=5, description="만족도 (1~5)")
    is_active: Optional[bool] = None
    month: Optional[str] = None
    
    @field_validator('user_satis')
    @classmethod
    def validate_user_satis(cls, v: Optional[int]) -> Optional[int]:
        if v is not None and not (1 <= v <= 5):
            raise ValueError('user_satis는 1~5 사이의 정수여야 합니다.')
        return v
    
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

# 별점 모델
class SubscriptionRatingUpdateRequest(BaseModel):
    user_id: str 
    app_name: str 
    user_satis: int = Field(..., ge=1, le=5, description="만족도 (1~5)")
    month: Optional[str] = None  # 월별로 별점 저장할 경우
    
    @field_validator('user_satis')
    @classmethod
    def validate_user_satis(cls, v: int) -> int:
        if not (1 <= v <= 5):
            raise ValueError('user_satis는 1~5 사이의 정수여야 합니다.')
        return v