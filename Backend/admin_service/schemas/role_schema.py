from pydantic import BaseModel

class RoleCreate(BaseModel):
    name: str

class RoleDelete(BaseModel):
    name: str 

class RoleModify(BaseModel):
    old_name: str 
    new_name: str 