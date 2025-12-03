## 🚀 Kubernetes 로컬 환경 배포 가이드

Docker Desktop에서 Kubernetes(K8s)를 시작한 후 진행하시면 됩니다.

`docker-compose.yml` 파일은 K8s 배포의 원본 소스로만 사용되며, 실제 배포는 `kompose`로 변환된 `.yaml` 파일들을 사용합니다.

> **중요:** 이 가이드는 `backend-deployment.yaml` 및 `db-deployment.yaml` 파일에서 민감 정보(DB 비밀번호 등)가 모두 `Secret`을 참조하도록 작성

-----

### 1\. K8s 환경 설정 (최초 1회)

1.  **Backend 이미지 빌드**
    K8s는 `build`를 수행하지 않으므로, 로컬에 `fastapi-app:local` 이미지를 미리 빌드합니다.

    ```bash
    docker build -t fastapi-app:local .
    ```

2.  **Firebase Secret 생성**
    (`service_account_key.json` 파일이 있는 루트에서 실행)

    ```bash
    kubectl create secret generic firebase-key-secret --from-file=service_account_key.json
    ```

3.  **Postgres DB Secret 생성**
    K8s 클러스터 공용 `USER`와 `PASSWORD`로 Secret을 생성합니다. (팀원 간 값 통일 필요)

    ```bash
    kubectl create secret generic postgres-secret \
      --from-literal=POSTGRES_USER=admin \
      --from-literal=POSTGRES_PASSWORD=1234
    ```

-----

### 2\. K8s 실행 및 확인

1.  **애플리케이션 배포**

    ```bash
    kubectl apply -f .
    ```

    > `docker-compose.yml`이나 `.json` 파일에 대한 경고(validation error)가 표시될 수 있으나, K8s 파일이 아니므로 정상적으로 무시됩니다.

2.  **Pod 상태 확인**
    `db`, `redis`, `backend` 3개의 Pod가 `Running` 상태가 될 때까지 확인합니다.

    ```bash
    kubectl get pods -w
    ```
