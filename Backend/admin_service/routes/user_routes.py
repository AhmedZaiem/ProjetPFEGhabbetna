from typing import List

from fastapi import APIRouter, HTTPException, Depends
from sqlalchemy.orm import Session
from db.database import get_db
from schemas.userSchema import UserOut , UserUpdate
from schemas.role_schema import RoleCreate , RoleDelete , RoleModify
from services.user_service import get_all_users,block_user,unblock_user,create_role,get_roles,delete_role,modify_role,get_non_assigned_agents,get_all_supervisors,update_user,update_user_score
from core.security import hash_password, verify_password,create_access_token
from models import User

router = APIRouter(prefix="/users", tags=["User"])

@router.get("/users", response_model=list[UserOut])
def read_users(
    db: Session = Depends(get_db)
):
    return get_all_users(db)




@router.post("/create-role")
def create_role_route(role: RoleCreate, db: Session = Depends(get_db)):
    new_role = create_role(db,role.name)

    if new_role is None:
        raise HTTPException(status_code=400, detail="Role already exists")

    return {"message": "Role created successfully", "role": new_role}


@router.get("/roles")
def get_roles_route(db: Session = Depends(get_db)):
    return get_roles(db)
    

@router.delete("/delete-role")
def delete_role_route(name: str, db: Session = Depends(get_db)):
    deleted = delete_role(db, name)
    if not deleted:
        raise HTTPException(status_code=404, detail="Role not found")
    return {"message": "Role deleted successfully", "role": deleted.name} 

@router.put("/modify-role")
def modify_role_route(role: RoleModify, db: Session = Depends(get_db)):
    result = modify_role(db, role.old_name, role.new_name)

    if result is None:
        raise HTTPException(status_code=404, detail="Original role not found")
    elif result == "exists":
        raise HTTPException(status_code=400, detail="New role name already exists")

    return {"message": "Role updated successfully", "role": result.name}

@router.get("/agents/unassigned")
def get_free_agents(db: Session = Depends(get_db)):
    agents = get_non_assigned_agents(db)
    return agents

@router.get("/supervisors")
def get_supervisors(db: Session = Depends(get_db)):
    supervisors = get_all_supervisors(db)
    return supervisors

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

@router.get("/{user_id}", response_model=UserOut)
def get_user_by_id(
    user_id: int,
    db: Session = Depends(get_db)
):
    user = db.query(User).filter(User.id == user_id).first()

    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    return user



@router.put("/{user_id}", response_model=UserOut)
def update_user_route(
    user_id: int,
    user: UserUpdate,
    db: Session = Depends(get_db)
):
    return update_user(
        db,
        user_id,
        user.firstname,
        user.lastname,
        user.cin,
        user.username,
        user.email,
        user.role_name,
        user.age,
        user.region,
        user.tel
    )

@router.put("/{user_id}/score")
def set_user_score(
    user_id: int,
    score: int,
    db: Session = Depends(get_db)
):
    return update_user_score(db, user_id, score)