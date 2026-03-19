from fastapi import APIRouter, HTTPException
from schemas.auth_schemas import LoginRequest, ActivationRequest, PasswordResetRequest, PasswordReset, ActivateAccountRequest
from core.security import verify_password, create_access_token, create_refresh_token,decode_token
from services.email_service import send_activation_email, send_password_reset_email

import httpx
import uuid
import jwt
from core.redis_client import redis_client

router = APIRouter(prefix="/auth", tags=["Auth"])

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

    access_token = create_access_token(
        data={
            "user_id": user["id"],
            "sub": user["email"],
            "role_id": user["role_id"]
        }
    )

    session_id = str(uuid.uuid4())

    refresh_token = create_refresh_token(
        data={
            "user_id":user["id"],
            "sub": user["email"],
            "role_id":user["role_id"],
            "sid": session_id
        }
    )

    redis_client.setex(f"refresh:{user['id']}:{session_id}",7*24*3600,refresh_token)

    return {
        "access_token": access_token,
        "refresh_token": refresh_token,
        "token_type": "bearer"
    }

@router.post("/refresh")
async def refresh_token(refresh_token: str):
    try:
        payload = decode_token(refresh_token)

        user_id = payload.get("user_id")
        session_id = payload.get("sid")

        if not user_id or not session_id:
            raise HTTPException(status_code=401, detail="Invalid token")
        
        stored_token = redis_client.get(f"refresh:{user_id}:{session_id}")

        if stored_token is None:
            raise HTTPException(status_code=401, detail="Session expired")
        
        if stored_token.decode() != refresh_token:
            raise HTTPException(status_code=401, detail="Token mismatch")
        
        new_access_token = create_access_token(
            data={
                "user_id": user_id,
                "sub": payload.get("sub"),
                "role_id": payload.get("role_id")
            }
        )

        new_refresh_token = create_refresh_token(
            data={
                "user_id": user_id,
                "sub": payload.get("sub"),
                "role_id": payload.get("role_id"),
                "sid": session_id
            }
        )

        redis_client.setex(
            f"refresh:{user_id}:{session_id}",
            7 * 24 * 3600,
            new_refresh_token
        )

        return {
            "access_token": new_access_token,
            "refresh_token": new_refresh_token
        }
    except jwt.ExpiredSignatureError:
        raise HTTPException(status_code=401, detail="Refresh token expired")

    except jwt.InvalidTokenError:
        raise HTTPException(status_code=401, detail="Invalid token")


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