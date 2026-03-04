from pydantic import BaseModel, EmailStr, Field

class UserCreate(BaseModel):
    username: str = Field(min_length=3, max_length=50)
    email: EmailStr
    age: int
    role_name: str

class UserLogin(BaseModel):
    email: EmailStr
    password: str = Field(min_length=8)

class UserActivate(BaseModel):
    token: str
    password: str = Field(min_length=8)

class PasswordResetRequest(BaseModel):
    email: EmailStr

class PasswordReset(BaseModel):
    token: str
    new_password: str = Field(min_length=8)

class UserOut(BaseModel):
    id: int
    username: str
    email: EmailStr
    age: int
    role_name: str
    is_verified: bool
    is_blocked: bool

    class Config:
        orm_mode = True
    
