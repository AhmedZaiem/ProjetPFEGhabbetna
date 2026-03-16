from db.database import get_db
from models.user import User
from models.role import Role
from sqlalchemy.orm import Session
from core.security import decode_access_token
from fastapi import HTTPException, Depends
from fastapi.security import OAuth2PasswordBearer,HTTPBearer
from fastapi_mail import MessageSchema
from core.email import fastMail
import os

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
    
def get_user_by_id(db: Session,user_id: int):
    return db.query(User).filter(User.id == user_id).first()

def create_user(db:Session,username:str, email: str,role_name: str, age: int):
    role = db.query(Role).filter(Role.name == role_name).first()
    if not role:
        raise HTTPException(status_code=400, detail="Invalid role")
    new_user = User(username=username, email=email,role_id=role.id, age=age)
    db.add(new_user)
    db.commit()
    db.refresh(new_user)
    return new_user

def get_all_users(db: Session):
    users = db.query(User).join(Role).filter(Role.name != "Admin").all()
    return [
        {
            "id": u.id,
            "username": u.username,
            "email": u.email,
            "age": u.age,
            "role_name": u.role.name,
            "is_verified": u.is_verified,
            "is_blocked": u.is_blocked
        }
        for u in users
    ]

def block_user(db: Session, user_id: int):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        return None
    user.is_blocked = True
    db.commit()
    db.refresh(user)
    return user

def unblock_user(db: Session, user_id: int):
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        return None
    user.is_blocked = False
    db.commit()
    db.refresh(user)
    return user


def create_role(db: Session, name: str):
    existing_role = db.query(Role).filter(Role.name == name).first()
    if existing_role:
        return None

    new_role = Role(name=name)
    db.add(new_role)
    db.commit()
    db.refresh(new_role)

    return new_role

def get_roles(db: Session):
    return db.query(Role).filter(Role.name != "Admin").all()


def delete_role(db: Session, name: str):
    role_selected = db.query(Role).filter(Role.name == name).first()
    if not role_selected:
        return None
    db.delete(role_selected)
    db.commit()
    return role_selected


def modify_role(db: Session, old_name: str, new_name: str):
    role_selected = db.query(Role).filter(Role.name == old_name).first()

    if not role_selected:
        return None

    existing_role = db.query(Role).filter(Role.name == new_name).first()
    if existing_role:
        return "exists"

    role_selected.name = new_name
    db.commit()
    db.refresh(role_selected)

    return role_selected
