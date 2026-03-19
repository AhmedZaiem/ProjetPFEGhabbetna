from models.user import User 
from fastapi import APIRouter, HTTPException, Depends
from schemas.userSchema import UserCreate
from services.user_service import get_user_by_email, create_user,get_current_user
from core.security import hash_password

from sqlalchemy.orm import Session
from db.database import get_db

import httpx

AUTH_SERVICE_URL = "http://localhost:8001"

router = APIRouter(prefix="/auth", tags=["Auth"])

@router.get("/me")
def read_current_user(current_user: User = Depends(get_current_user)):
    return current_user

@router.post("/register")
async def register(user: UserCreate, db: Session = Depends(get_db)):

    if get_user_by_email(db, user.email):
        raise HTTPException(status_code=400, detail="Email already registered")

    new_user = create_user(
        db,
        user.username,
        user.email,
        user.role_name,
        user.age
    )

    async with httpx.AsyncClient() as client:
        await client.post(
            f"{AUTH_SERVICE_URL}/auth/send-activation",
            json={
                "user_id": new_user.id,
                "email": new_user.email
            }
        )

    return {"message": "User registered successfully"}

@router.get("/users/by-email/{email}")
def get_user_by_email_endpoint(email: str, db: Session = Depends(get_db)):

    user = get_user_by_email(db, email)

    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    return {
        "id": user.id,
        "email": user.email,
        "password_hash": user.password_hash,
        "is_verified": user.is_verified,
        "is_blocked": user.is_blocked,
        "role_id": user.role_id
    }

@router.patch("/users/{user_id}/password")
def update_password(user_id: int, payload: dict, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.id == user_id).first()

    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    user.password_hash = hash_password(payload["new_password"])
    db.commit()

    return {"message": "Password updated"}

@router.post("/users/{user_id}/activate")
def activate_user(user_id: int, payload: dict, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    user.password_hash = hash_password(payload["password"])
    user.is_verified = True
    db.commit()
    return {"message": "User activated"}