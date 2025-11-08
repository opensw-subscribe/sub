from fastapi import Depends, FastAPI, Request
from app.core.firebase import firebase_auth
from app.db import models, session
from app.routers import users, subscriptions, analysis
from app.routers.users import router as users_router

models.Base.metadata.create_all(bind=session.engine)

app = FastAPI(title="Subscription Backend API")

@app.get("/test")
async def test(request: Request, token=Depends(firebase_auth)):
    return {"message": "Firebase 인증 성공", "uid": request.state.user_id}

app.include_router(users.router)
app.include_router(subscriptions.router)
app.include_router(analysis.router)

@app.get("/")
def root():
    return {"message": "🚀 Backend API is running!"}