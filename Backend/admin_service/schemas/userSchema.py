from pydantic import BaseModel, EmailStr, Field

class UserCreate(BaseModel):
    firstname: str
    lastname: str
    cin: str = Field(min_length=8, max_length=8)
    username: str = Field(min_length=3, max_length=50)
    email: EmailStr
    age: int
    role_name: str
    region: str
    tel: str


class UserUpdate(BaseModel):
    firstname: str
    lastname: str
    cin: str = Field(min_length=8, max_length=8)
    username: str = Field(min_length=3, max_length=50)
    email: EmailStr
    age: int
    role_name: str
    region: str
    tel: str


class UserOut(BaseModel):
    id: int
    firstname: str
    lastname: str
    cin: str
    username: str
    email: EmailStr
    age: int
    role_name: str
    is_verified: bool
    is_blocked: bool
    region: str
    tel: str
    score: int 

    class Config:
        orm_mode = True

class scoreUpdate(BaseModel):
    score: int
    
