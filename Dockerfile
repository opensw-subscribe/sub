# 1. Python 3.10 기반 이미지 사용
FROM python:3.10-slim

# 2. 컨테이너 안에서 실행될 작업 디렉토리 설정
WORKDIR /app

# 3. 로컬 requirements.txt 복사 후 의존성 설치
COPY requirements.txt .

# pip 최신화 + 설치
RUN pip install --upgrade pip
RUN pip install --no-cache-dir -r requirements.txt

# 4. 나머지 FastAPI 소스코드 복사
COPY . .

# 5. FastAPI 앱 실행 (Uvicorn 서버)
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
