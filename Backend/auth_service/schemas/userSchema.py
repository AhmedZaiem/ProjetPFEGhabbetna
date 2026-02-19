from pydantic import BaseModel, EmailStr, Field
from models.enums import UserRole

class UserCreate(BaseModel):
    username: str = Field(min_length=3, max_length=50)
    email: EmailStr
    age: int
    role: UserRole

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
    
