from fastapi import APIRouter, HTTPException
from schemas.auth_schemas import LoginRequest, ActivationRequest, PasswordResetRequest, PasswordReset, ActivateAccountRequest
from core.security import verify_password, create_access_token
from services.email_service import send_activation_email, send_password_reset_email

import httpx
import uuid
from core.redis_client import redis_client

router = APIRouter(prefix="/auth", tags=["Auth"])

# Initialize Redis client


ADMIN_SERVICE_URL = "http://localhost:8002"


@router.post("/login")
async def login(data: LoginRequest):

    async with httpx.AsyncClient() as client:
        response = await client.get(
            f"{ADMIN_SERVICE_URL}/auth/users/by-email/{data.email}"
        )

    if response.status_code != 200:
        raise HTTPException(status_code=401, detail="Invalid credentials")

    user = response.json()

    if not verify_password(data.password, user["password_hash"]):
        raise HTTPException(status_code=401, detail="Invalid credentials")

    if not user["is_verified"]:
        raise HTTPException(status_code=403, detail="Account not activated")

    if user["is_blocked"]:
        raise HTTPException(status_code=403, detail="Account blocked")

    token = create_access_token(
        data={
            "user_id": user["id"],
            "sub": user["email"],
            "role_id": user["role_id"]
        }
    )

    return {
        "access_token": token,
        "token_type": "bearer"
    }


@router.post("/send-activation")
async def send_activation(data: ActivationRequest):

    token = str(uuid.uuid4())

    redis_client.setex(
        f"activation:{token}",
        86400,
        data.user_id
    )

    await send_activation_email(data.email, token)

    return {"message": "Activation email sent"}

@router.post("/activate")
async def activate_account(data: ActivateAccountRequest):

    user_id = redis_client.get(f"activation:{data.token}")

    if not user_id:
        raise HTTPException(status_code=400, detail="Invalid token")

    async with httpx.AsyncClient() as client:
        await client.post(
            f"{ADMIN_SERVICE_URL}/auth/users/{user_id}/activate",
            json={"password": data.password}
        )

    redis_client.delete(f"activation:{data.token}")

    return {"message": "Account activated"}

@router.post("/forgot-password")
async def forgot_password(data: PasswordResetRequest):
    # Ask Admin Service for user by email
    async with httpx.AsyncClient() as client:
        response = await client.get(f"{ADMIN_SERVICE_URL}/auth/users/by-email/{data.email}")

    if response.status_code != 200:
        raise HTTPException(status_code=404, detail="User not found")

    user = response.json()

    if not user["is_verified"]:
        raise HTTPException(status_code=403, detail="Account not activated")

    # Generate reset token and store in Redis
    token = str(uuid.uuid4())
    redis_client.setex(f"reset:{token}", 3600, user["id"])  # 1 hour TTL

    # Send email
    await send_password_reset_email(user["email"], token)

    return {"message": "Password reset email sent"}

@router.post("/reset-password")
async def reset_password(data: PasswordReset):
    # Get user_id from Redis
    user_id = redis_client.get(f"reset:{data.token}")

    if not user_id:
        raise HTTPException(status_code=400, detail="Invalid or expired reset token")

    # Call Admin Service to update password
    async with httpx.AsyncClient() as client:
        await client.patch(
            f"{ADMIN_SERVICE_URL}/auth/users/{user_id}/password",
            json={"new_password": data.new_password}
        )

    # Delete token from Redis
    redis_client.delete(f"reset:{data.token}")

    return {"message": "Password reset successfully"}