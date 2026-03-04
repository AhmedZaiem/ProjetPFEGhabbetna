from models.user import User 
from models.role import Role
from fastapi import APIRouter, HTTPException, Depends
from schemas.userSchema import UserCreate, UserLogin, UserActivate, PasswordResetRequest, PasswordReset, UserOut
from services.user_service import get_user_by_email, create_user,get_current_user,send_activation_email,send_password_reset_email,get_all_users,block_user,unblock_user
from core.security import hash_password, verify_password,create_access_token

from sqlalchemy.orm import Session
from db.database import get_db
import uuid
#from services.user_producer import publish_user_event

router = APIRouter(prefix="/auth", tags=["Auth"])

@router.get("/me")
def read_current_user(current_user: User = Depends(get_current_user)):
    return current_user

@router.post("/register")
async def register(user: UserCreate, db: Session = Depends(get_db)):
    if get_user_by_email(db, user.email):
        raise HTTPException(status_code=400, detail="Email already registered")

    activation_token = str(uuid.uuid4())
    new_user=create_user(db, user.username,user.email, user.role_name, user.age,activation_token=activation_token)

    #publish_user_event("REGISTER", new_user)
    await send_activation_email(new_user.email,activation_token)

    return {"message": "User registered successfully","token":new_user.activation_token}

@router.post("/login")
def login(user: UserLogin, db: Session = Depends(get_db)):
    db_user = get_user_by_email(db, user.email)

    if not db_user or not verify_password(user.password, db_user.password_hash):
        raise HTTPException(status_code=401, detail="Invalid email or password")
    
    if not db_user.is_verified or not db_user.password_hash:
        raise HTTPException(status_code=403,detail="Account not activated")
    
    if db_user.is_blocked:
        raise HTTPException(status_code=403, detail="Account is blocked")
    
    #publish_user_event("LOGIN", db_user)

    access_token = create_access_token(data={"user_id": db_user.id,"sub": db_user.email})

    return {"message": "Login successful", "access_token": access_token, "token_type": "bearer"}

@router.post("/activate")
def activate_account(data:UserActivate,db: Session = Depends(get_db)):
    user = db.query(User).filter(User.activation_token == data.token).first()

    if not user:
        raise HTTPException(status_code=400,detail="invalid activation token")
    
    if user.is_verified:
        raise HTTPException(status_code=400, detail="Account already activated")
    
    user.password_hash = hash_password(data.password)
    user.is_verified = True
    user.activation_token = None

    db.commit()

    return {"message": "Account activated successfully"}


@router.post("/forgot-password")
async def forgot_password(data:PasswordResetRequest, db: Session = Depends(get_db)):
    user = get_user_by_email(db, data.email)

    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    if not user.is_verified:
        raise HTTPException(status_code=403, detail="Account not activated")

    reset_token = str(uuid.uuid4())
    user.activation_token = reset_token  # Reusing activation_token for simplicity
    db.commit()

    await send_password_reset_email(user.email, reset_token)

    return {"message": "Password reset email sent", "reset_token": reset_token}

@router.post("/reset-password")
def reset_password(data: PasswordReset, db: Session = Depends(get_db)):
    user = db.query(User).filter(User.activation_token == data.token).first()

    if not user:
        raise HTTPException(status_code=400, detail="Invalid reset token")

    user.password_hash = hash_password(data.new_password)
    user.activation_token = None  # Clear the token after use
    db.commit()

    return {"message": "Password reset successfully"}

@router.get("/users", response_model=list[UserOut])
def read_users(
    db: Session = Depends(get_db)
):
    return get_all_users(db)

@router.post("/users/{user_id}/block")
def block_user_route(user_id: int, db: Session = Depends(get_db)):
    user = block_user(db, user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user

@router.post("/users/{user_id}/unblock")
def unblock_user_route(user_id: int, db: Session = Depends(get_db)):
    user = unblock_user(db, user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user

@router.post("/roles")
def create_role(name: str, db: Session = Depends(get_db)):
    existing_role = db.query(Role).filter(Role.name == name).first()
    if existing_role:
        raise HTTPException(status_code=400, detail="Role already exists")
    
    new_role = Role(name=name)
    db.add(new_role)
    db.commit()
    db.refresh(new_role)

    return {"message": "Role created successfully", "role": new_role}

@router.get("/roles")
def get_roles(db: Session = Depends(get_db)):
    roles = db.query(Role).filter(Role.name != "Admin").all()
    return roles
    
