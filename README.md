# 🚀 로컬 Kubernetes(minikube) 환경 배포 가이드
## 이 가이드는 **FastAPI + Postgres + Redis**를 minikube 환경에서 로컬로 실행하는 방법을 안내합니다.

> ⚠️ Docker Desktop이 켜져 있어야 하며, Windows 환경에서는 Docker 드라이버 사용을 가정합니다.


### 1️⃣ minikube 시작
```powershell
minikube start --driver=docker
```
* 이미 빌드했다면 생략 가능

### 2️⃣ backend 이미지 빌드 (이미 했으면 생략 가능)
```powershell
docker build -t fastapi-app:local .
```


### 3️⃣ 이미지 minikube에 로드
```powershell
minikube image load fastapi-app:local
```
* minikube는 Docker Desktop과 별도로 이미지를 관리하므로 반드시 필요

### 4️⃣ Firebase Secret 생성
```powershell
kubectl create secret generic firebase-key-secret --from-file=service_account_key.json
```

### 5️⃣ Postgres Secret 생성
```powershell
kubectl create secret generic postgres-secret --from-literal=POSTGRES_USER=postgres --from-literal=POSTGRES_PASSWORD=1234
```
* PowerShell에서는 위 명령어 그대로 사용가능
* CMD에서는 줄바꿈 시 ^ 대신 \ 사용

### 6️⃣ YAML 적용
```powershell
kubectl apply -f k8s/
```
* k8s 폴더에 있는 .yaml 파일을 모두 적용
* backend, db, redis Deployment 및 Service가 생성됨

### 7️⃣ Pod 상태 확인
```powershell
kubectl get pods -w
```
* Pod 상태가 Running이 될 때까지 대기
* 종료하려면 Ctrl + C를 눌러 watch 모드 종료 가능

### 8️⃣ FastAPI 서비스 URL 확인
```powershell
minikube service backend --url
```
* 출력된 URL을 브라우저나 Postman에서 접속 가능
* 예: http://127.0.0.1:64574

**추가 명령어**
* 모든 서비스 목록 확인: 
```powershell
minikube service list
```
* Pod 로그 확인:
```powershell
kubectl logs <pod-name>
```
* Pod 상태와 이벤트 확인:
```powershell
kubectl describe pod <pod-name>
```