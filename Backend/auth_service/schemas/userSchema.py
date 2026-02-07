from pydantic import BaseModel, EmailStr, Field

class UserCreate(BaseModel):
    username: str = Field(min_length=3, max_length=50)
    email: EmailStr
    password: str = Field(min_length=8)
    age: int

class UserLogin(BaseModel):
    email: EmailStr
    password: str = Field(min_length=8)

