from sqlalchemy import Column, Integer, String, Boolean, ForeignKey, Numeric, SmallInteger, DateTime
from sqlalchemy.orm import relationship, declarative_base
from datetime import datetime

Base = declarative_base()


Base = declarative_base()

class User(Base):
    __tablename__ = "users"

    user_id = Column(String, primary_key=True, index=True)  # Firebase UID
    email = Column(String, unique=True, nullable=False)     # 추가
    user_name = Column(String(100), nullable=False)         # name → user_name

    created_at = Column(DateTime, default=datetime.utcnow)
    last_login_at = Column(DateTime, default=datetime.utcnow)
    
    subscriptions = relationship("Subscription", back_populates="user")

class Category(Base):
    __tablename__ = "categories"

    category_id = Column(Integer, primary_key=True, index=True)
    category_name = Column(String(50), unique=True, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)
    subscriptions = relationship("Subscription", back_populates="category")

class Subscription(Base):
    __tablename__ = "subscriptions"

    sub_id = Column(Integer, primary_key=True, index=True)
    user_id = Column(String, ForeignKey("users.user_id"), nullable=False)
    app_name = Column(String(100), nullable=False)
    category_id = Column(Integer, ForeignKey("categories.category_id"), nullable=False)
    service_monthly_price = Column(Numeric(10,2), nullable=False)
    service_once_price = Column(Numeric(10,2), default=0)
    service_usage_time = Column(Integer, nullable=False)
    service_usage = Column(Integer, nullable=False)
    weekly_usage_hours = Column(Numeric(5,2), default=0)
    user_satis = Column(SmallInteger, nullable=False)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    month = Column(String, nullable=False, default=lambda: datetime.utcnow().strftime("%Y-%m"))

    user = relationship("User", back_populates="subscriptions")
    category = relationship("Category", back_populates="subscriptions")
    analysis_results = relationship("AnalysisResult", back_populates="subscription")

class AnalysisResult(Base):
    __tablename__ = "analysis_result"

    result_id = Column(Integer, primary_key=True, index=True)
    sub_id = Column(Integer, ForeignKey("subscriptions.sub_id"), nullable=False)
    calculated_cph = Column(Numeric(10,2), nullable=False)
    quadrant_type = Column(String(50), nullable=False)
    last_analyzed_at = Column(DateTime, default=datetime.utcnow)

    subscription = relationship("Subscription", back_populates="analysis_results")
