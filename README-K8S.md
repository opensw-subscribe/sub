🚀 Kubernetes 로컬 환경 배포 가이드

Kubernetes(K8s) 환경에서 실행할 수 있습니다 -> Docker에서 k8s 시작 후 진행하시면 됩니다. 
docker-compose.yml 파일은 K8s 배포의 원본 소스로만 사용되며, 실제 배포는 kompose로 변환된 .yaml 파일들을 사용합니다.
중요: 이 가이드는 backend-deployment.yaml 및 db-deployment.yaml 파일에서 민감 정보(DB 비밀번호 등)가 모두 Secret을 참조하도록 작성되었습니다.

K8s 환경 설정 (최초 1회)
1. K8s는 build를 수행하지 않으므로, 로컬에 fastapi-app:local 이미지를 미리 빌드: docker build -t fastapi-app:local .
2. Firebase Secret 생성
(service_account_key.json 파일이 있는 루트에서 실행)
kubectl create secret generic firebase-key-secret --from-file=service_account_key.json
3. Postgres DB Secret 생성
kubectl create secret generic postgres-secret \
  --from-literal=POSTGRES_USER=admin \
  --from-literal=POSTGRES_PASSWORD=1234

k8s 실행 : kubectl apply -f .
docker-compose.yml이나 .json 파일에 대한 경고(validation error)가 표시될 수 있으나, K8s 파일이 아니므로 정상적으로 무시 가능
Pod 상태 확인 : kubectl get pods -w
