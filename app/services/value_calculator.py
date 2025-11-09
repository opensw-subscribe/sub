# app/services/value_calculator.py
from math import log

TMAX = 1440  # 하루 24시간 * 60분
NMAX = 50    # 하루 최대 실행 횟수

def value_score_log(T: float, N: int, mode: str = "T") -> int:
    """로그 기반 ValueScore 계산 (0~100 정수 반환)"""
    if mode.upper() == "T":
        w1, w2 = 0.7, 0.3
    elif mode.upper() == "N":
        w1, w2 = 0.3, 0.7
    else:
        raise ValueError("mode는 'T' 또는 'N' 이어야 합니다.")

    sT = log(1 + T) / log(TMAX)
    sN = log(1 + N) / log(NMAX)
    score = max(0.0, min(w1 * sT + w2 * sN, 1.0))
    return round(score * 100)

def cost_per_use(monthly_cost: float, T: float, N: int, alpha: float) -> float:
    """1회 이용 비용 계산"""
    monthly_cost_f = float(monthly_cost)

    effective_uses = N + alpha * (T / 60)
    return round(monthly_cost_f / effective_uses, 0) if effective_uses > 0 else monthly_cost_f

def recommend_alpha(category: str) -> float:
    """서비스 유형에 따라 알파 값 추천"""
    category = category.lower()
    if category in ["video"]:
        return 2.0
    elif category in ["music"]:
        return 1.5
    elif category in ["shopping", "delivery"]:
        return 0.5
    else:
        return 1.0

def default_mode(category: str) -> str:
    """서비스 유형에 따라 ValueScore 모드 추천"""
    category = category.lower()
    if category in ["video", "music"]:
        return "T"
    else:
        return "N"
