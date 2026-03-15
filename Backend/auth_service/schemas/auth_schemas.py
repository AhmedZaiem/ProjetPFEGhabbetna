from pydantic import BaseModel, EmailStr


class LoginRequest(BaseModel):
    email: EmailStr
    password: str


class ActivationRequest(BaseModel):
    user_id: int
    email: EmailStr


class PasswordResetRequest(BaseModel):
    email: EmailStr


class PasswordReset(BaseModel):
    token: str
    new_password: str

class ActivateAccountRequest(BaseModel):
    token: str
    password: str