## backend 요약

### 1. 기술 스택 및 구성

* **웹 프레임워크:** **FastAPI**
* **데이터베이스:** **PostgreSQL**
* **캐시:** **Redis**
* **인증:** Firebase
* **구성:** 3개 컨테이너 (FastAPI, DB, Redis)

### 2. 캐싱 전략 (TTL 기반)

* **정책:** 캐시 만료 시간 (**TTL**, 3600초)에만 의존합니다.
* **Write/Update 시:** 데이터 수정 시 Redis 캐시를 **강제로 삭제하지 않습니다.**
* **결과:** 데이터 수정 후 **최대 1시간 동안** 구 버전 데이터(Stale Data)가 조회될 수 있습니다. (코드를 단순화하기 위한 의도적인 선택)

### 3. 필수 실행 명령어

| 명령어 | 역할 |
| :--- | :--- |
| `docker compose up --build` | **최초 실행 및 업데이트** (컨테이너 빌드 및 시작) |
| `docker compose up -d` | **백그라운드 실행** (개발 및 운영) |
| `docker compose down -v` | **전체 초기화** (컨테이너, 네트워크, DB/Redis 데이터 모두 삭제) |
| `docker compose logs fastapi-app -f` | **FastAPI 실시간 로그 확인** (디버깅 시 가장 중요) |

---

### 4. 접속 정보

* **API 주소:** `http://localhost:8000`
* **API 문서:** `http://localhost:8000/docs` (Swagger UI)