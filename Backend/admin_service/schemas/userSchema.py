from pydantic import BaseModel, EmailStr, Field

class UserCreate(BaseModel):
    username: str = Field(min_length=3, max_length=50)
    email: EmailStr
    age: int
    role_name: str


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
    
