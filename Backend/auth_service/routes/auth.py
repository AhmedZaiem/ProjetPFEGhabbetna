from models.user import User
from fastapi import APIRouter, HTTPException, Depends
from schemas.userSchema import UserCreate, UserLogin
from services.user_service import get_user_by_email, create_user,get_current_user
from core.security import hash_password, verify_password,create_access_token
from sqlalchemy.orm import Session
from db.database import get_db
#from services.user_producer import publish_user_event

router = APIRouter(prefix="/auth", tags=["Auth"])

@router.get("/me")
def read_current_user(current_user: User = Depends(get_current_user)):
    return current_user

@router.post("/register")
def register(user: UserCreate, db: Session = Depends(get_db)):
    if get_user_by_email(db, user.email):
        raise HTTPException(status_code=400, detail="Email already registered")

    hashed_password = hash_password(user.password)
    new_user=create_user(db, user.username,user.email, hashed_password, user.age)

    #publish_user_event("REGISTER", new_user)
    return {"message": "User registered successfully"}

@router.post("/login")
def login(user: UserLogin, db: Session = Depends(get_db)):
    db_user = get_user_by_email(db, user.email)

    if not db_user or not verify_password(user.password, db_user.password):
        raise HTTPException(status_code=401, detail="Invalid email or password")
    
    #publish_user_event("LOGIN", db_user)

    access_token = create_access_token(data={"sub": db_user.email})

    return {"message": "Login successful", "access_token": access_token, "token_type": "bearer"}
