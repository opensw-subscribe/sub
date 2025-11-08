from dotenv import load_dotenv
import firebase_admin
from firebase_admin import credentials, auth
from fastapi import FastAPI, HTTPException, Request, Depends
import os

# Firebase Admin SDK 초기화
load_dotenv(dotenv_path=r"D:\swproject\backend\.env", override=True)
SERVICE_ACCOUNT_KEY_PATH = os.getenv("FIREBASE_KEY_PATH")

if not SERVICE_ACCOUNT_KEY_PATH:
    raise RuntimeError("환경 변수 FIREBASE_KEY_PATH가 설정되지 않았습니다.")

if not firebase_admin._apps:
    cred = credentials.Certificate(SERVICE_ACCOUNT_KEY_PATH)
    firebase_admin.initialize_app(cred)

# 토큰 검증 미들웨어
async def firebase_auth(request: Request):
    auth_header = request.headers.get("Authorization")
    if not auth_header or not auth_header.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Authorization header missing or invalid")

    id_token = auth_header.split(" ")[1]
    try:
        decoded_token = auth.verify_id_token(id_token)
        request.state.user_id = decoded_token["uid"]  # 필요 시 라우터에서 사용 가능
        return decoded_token
    except Exception as e:
        raise HTTPException(status_code=401, detail=f"Invalid token: {str(e)}")