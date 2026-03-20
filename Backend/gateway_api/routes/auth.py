from fastapi import APIRouter,Request,Response
import httpx
from fastapi.responses import JSONResponse
import json

router = APIRouter()

Auth_SERVICE_URL = "http://localhost:8001"

Admin_SERVICE_URL= "http://localhost:8002"

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
        response = await client.post(f"{Admin_SERVICE_URL}/auth/register", json=body)
    return response.json()

@router.post("/refresh")
async def refresh(request: Request):
    body = await request.json()

    async with httpx.AsyncClient() as client:
        response = await client.post(
            f"{Auth_SERVICE_URL}/auth/refresh",
            json=body
        )
    return JSONResponse(
        status_code=response.status_code,
        content=response.json()
    )

@router.post("/logout")
async def logout(request: Request):
    body = await request.json()

    async with httpx.AsyncClient() as client:
        response = await client.post(
            f"{Auth_SERVICE_URL}/auth/logout",
            json=body
        )
    return JSONResponse(
        status_code=response.status_code,
        content=response.json()
    )

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
        response = await client.get(f"{Admin_SERVICE_URL}/auth/me", headers=headers)
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
    headers = {}
    auth = request.headers.get("Authorization")
    if auth:
        headers["Authorization"] = auth
    async with httpx.AsyncClient() as client:
        response = await client.get(f"{Admin_SERVICE_URL}/users/users", headers=headers)
    return Response(
        content=response.content,
        status_code=response.status_code,
        media_type="application/json"
    )



@router.post("/users/{user_id}/block")
async def block_user(user_id: int, request: Request):
    auth_header = request.headers.get("Authorization")
    headers = {"Authorization": auth_header} if auth_header else {}

    async with httpx.AsyncClient() as client:
        response = await client.post(
            f"{Admin_SERVICE_URL}/users/users/{user_id}/block",
            headers=headers
        )

    return JSONResponse(content=response.json(), status_code=response.status_code)


@router.post("/users/{user_id}/unblock")
async def unblock_user(user_id: int, request: Request):
    auth_header = request.headers.get("Authorization")
    headers = {"Authorization": auth_header} if auth_header else {}

    async with httpx.AsyncClient() as client:
        response = await client.post(
            f"{Admin_SERVICE_URL}/users/users/{user_id}/unblock",
            headers=headers
        )

    return JSONResponse(content=response.json(), status_code=response.status_code)



@router.post("/create-role")
async def create_role(request: Request):
    body = await request.json()

    headers = {}
    auth = request.headers.get("Authorization")
    if auth:
        headers["Authorization"] = auth

    async with httpx.AsyncClient() as client:
        response = await client.post(
            f"{Admin_SERVICE_URL}/users/create-role",
            json=body,
            headers=headers
        )

    return Response(
        content=response.content,
        status_code=response.status_code,
        media_type="application/json"
    )


@router.get("/roles")
async def get_roles(request: Request):
    headers = {}
    auth = request.headers.get("Authorization")
    if auth:
        headers["Authorization"] = auth

    async with httpx.AsyncClient() as client:
        response = await client.get(
            f"{Admin_SERVICE_URL}/users/roles",
            headers=headers
        )

    return Response(
        content=response.content,
        status_code=response.status_code,
        media_type="application/json"
    )


@router.delete("/delete-role")
async def delete_role(name: str, request: Request):
    headers = {}
    auth = request.headers.get("Authorization")
    if auth:
        headers["Authorization"] = auth

    async with httpx.AsyncClient() as client:
        response = await client.delete(
            f"{Admin_SERVICE_URL}/users/delete-role?name={name}",
            headers=headers
        )

    return Response(
        content=response.content,
        status_code=response.status_code,
        media_type="application/json"
    )

@router.put("/modify-role")
async def modify_role(request: Request):
    body = await request.json()  

    headers = {}
    auth = request.headers.get("Authorization")
    if auth:
        headers["Authorization"] = auth

    async with httpx.AsyncClient() as client:
        response = await client.put(
            f"{Admin_SERVICE_URL}/users/modify-role",
            headers=headers,
            json=body
        )

    return Response(
        content=response.content,
        status_code=response.status_code,
        media_type="application/json"
    )

@router.get("agents/unassigned")
async def get_unassigned_agents(request: Request):
    headers = {}
    auth = request.headers.get("Authorization")
    if auth:
        headers["Authorization"] = auth

    async with httpx.AsyncClient() as client:
        response = await client.get(
            f"{Admin_SERVICE_URL}/users/agents/unassigned",
            headers=headers
        )

    return Response(
        content=response.content,
        status_code=response.status_code,
        media_type="application/json"
    )
