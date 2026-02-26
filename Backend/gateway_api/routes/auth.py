from fastapi import APIRouter,Request,Response
import httpx

router = APIRouter()

Auth_SERVICE_URL = "http://localhost:8001"

@router.post("/login")
async def login(request: Request):
    body = await request.json()
    async with httpx.AsyncClient() as client:
        response = await client.post(f"{Auth_SERVICE_URL}/auth/login", json=body)
    return response.json()

@router.post("/register")
async def register(request: Request):
    body = await request.json()
    async with httpx.AsyncClient() as client:
        response = await client.post(f"{Auth_SERVICE_URL}/auth/register", json=body)
    return response.json()

@router.post("/activate")
async def activate(request: Request):
    body = await request.json()
    async with httpx.AsyncClient() as client:
        response = await client.post(f"{Auth_SERVICE_URL}/auth/activate", json=body)
        
    return Response(
        content=response.content,
        status_code=response.status_code,
        media_type="application/json"
    )

@router.get("/me")
async def read_current_user(request: Request):
    headers = {
        "Authorization": request.headers.get("Authorization")
    }
    async with httpx.AsyncClient() as client:
        response = await client.get(f"{Auth_SERVICE_URL}/auth/me", headers=headers)
    return Response(
        content=response.content,
        status_code=response.status_code,
        media_type="application/json"
    )



@router.post("/forgot-password")
async def forgot_password(request: Request):
    body = await request.json()
    async with httpx.AsyncClient() as client:
        response = await client.post(
            f"{Auth_SERVICE_URL}/auth/forgot-password",
            json=body
        )
        return Response(
            content = response.content,
            status_code=response.status_code,
            media_type="application/json"
        )
    
@router.post("/reset-password")
async def reset_password(request:Request):
    body = await request.json()
    async with httpx.AsyncClient() as client:
        response = await client.post(
            f"{Auth_SERVICE_URL}/auth/reset-password",
            json=body
        )
    return Response(
        content=response.content,
        status_code=response.status_code,
        media_type="application/json"
    )


@router.get("/users")
async def get_all_users(request: Request):
    headers = {
        "Authorization": request.headers.get("Authorization")
    }
    async with httpx.AsyncClient() as client:
        response = await client.get(f"{Auth_SERVICE_URL}/auth/users", headers=headers)
    return Response(
        content=response.content,
        status_code=response.status_code,
        media_type="application/json"
    )

@router.post("/users/{user_id}/block")
async def block_user(user_id: int, request: Request):
    headers = {
        "Authorization": request.headers.get("Authorization")
    }

    async with httpx.AsyncClient() as client:
        response = await client.post(
            f"{Auth_SERVICE_URL}/auth/users/{user_id}/block",
            headers=headers
        )

    return Response(
        content=response.content,
        status_code=response.status_code,
        media_type="application/json"
    )


@router.post("/users/{user_id}/unblock")
async def unblock_user(user_id: int, request: Request):
    headers = {
        "Authorization": request.headers.get("Authorization")
    }

    async with httpx.AsyncClient() as client:
        response = await client.post(
            f"{Auth_SERVICE_URL}/auth/users/{user_id}/unblock",
            headers=headers
        )

    return Response(
        content=response.content,
        status_code=response.status_code,
        media_type="application/json"
    )