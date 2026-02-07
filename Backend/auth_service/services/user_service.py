from db.database import get_db
from models.user import User
from sqlalchemy.orm import Session
from core.security import decode_access_token
from fastapi import HTTPException, Depends
from fastapi.security import OAuth2PasswordBearer,HTTPBearer

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/auth/login")

bearer_scheme = HTTPBearer()

def get_current_user(
        token: str = Depends(oauth2_scheme),
        db: Session = Depends(get_db)
):
    payload = decode_access_token(token)
    if payload is None:
        raise HTTPException(status_code=401, detail="Invalid token")
    email: str = payload.get("sub")

    if email is None:
        raise HTTPException(status_code=401)
    user=get_user_by_email(db, email)
    if user is None:
        raise HTTPException(status_code=401)
    return user

def get_user_by_email(db: Session, email: str):
    return db.query(User).filter(User.email == email).first()
    
def create_user(db:Session,username:str, email: str, password: str, age: int):
    new_user = User(username=username, email=email, password=password, age=age)
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    return new_user
    
