# Subscription Backend API

FastAPI 기반 구독 관리 백엔드 프로젝트입니다.
PostgreSQL과 Redis를 사용하며, Firebase 인증과 연동되어 있습니다.

---

## 1. 의존성 설치

### 로컬 개발 환경 (선택 사항)

로컬에서 FastAPI를 실행하거나 테스트하려면 가상환경을 만들고 의존성을 설치합니다.

* venv 생성
  `python -m venv venv`

* 가상환경 활성화
  Windows: `venv\Scripts\activate`
  macOS/Linux: `source venv/bin/activate`

* 의존성 설치
  `pip install --upgrade pip`
  `pip install -r requirements.txt`

> ⚠️ Docker 환경에서는 컨테이너 빌드 시 requirements.txt가 자동으로 설치되므로 로컬 설치는 선택 사항입니다.

---

## 2. 환경 변수 설정

루트 디렉토리에 `.env` 파일 생성:

POSTGRES_USER=devuser
POSTGRES_PASSWORD=mysecretpassword
POSTGRES_DB=devdb
POSTGRES_PORT=5432

* Firebase 서비스 계정 키는 `service_account_key.json`으로 프로젝트 루트에 위치시킵니다.

---

## 3. Docker 컨테이너 실행

프로젝트는 3개의 컨테이너로 구성됩니다:

1. PostgreSQL (db)
2. Redis (cache)
3. FastAPI (backend)

### 실행 명령

`docker compose up --build`

* FastAPI: [http://localhost:8000](http://localhost:8000)
* PostgreSQL: 내부 포트 5432
* Redis: 내부 포트 6379

> FastAPI가 시작되면 DB 테이블이 자동으로 생성됩니다.
> Redis는 기본 설정으로 실행되며, 별도 config 파일 없이 사용 가능합니다.

---

## 4. API 테스트

* FastAPI 기본 테스트 엔드포인트
  `GET /test`

* Root 엔드포인트
  `GET /`
  Response: {"message": "🚀 Backend API is running!"}

---

## 5. 개발/테스트 팁

* 코드 변경 시 FastAPI 컨테이너를 재시작
  `docker compose up --build`

* DB 초기화가 필요하면 PostgreSQL 볼륨 삭제 후 재실행
  `docker compose down -v`
  `docker compose up --build`

---

## 6. 프로젝트 주요 구조

backend/
├─ app/
│  ├─ main.py
│  ├─ routers/
│  ├─ db/
│  └─ core/
├─ Dockerfile
├─ docker-compose.yml
├─ requirements.txt
├─ .env
└─ service_account_key.json

---

## 7. 주요 의존성

* fastapi
* uvicorn[standard]
* SQLAlchemy
* psycopg2-binary
* firebase-admin
* python-dotenv
* pydantic
* httpx
* alembic
* requests
* pytest
* pytest-asyncio