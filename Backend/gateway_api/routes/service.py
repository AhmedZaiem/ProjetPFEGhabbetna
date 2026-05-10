from fastapi import APIRouter, Request, Response
import httpx
import os

router = APIRouter()

Admin_SERVICE_URL = os.getenv("ADMIN_SERVICE_URL", "http://localhost:8002")

@router.get("/services")
async def get_services(request: Request):
    headers = {}
    auth = request.headers.get("Authorization")
    if auth:
        headers["Authorization"] = auth
    async with httpx.AsyncClient() as client:
        response = await client.get(f"{Admin_SERVICE_URL}/service/services", headers=headers)
    return Response(
        content=response.content,
        status_code=response.status_code,
        media_type="application/json"
    )

@router.post("/create_service")
async def create_service(request: Request):
    body = await request.json()
    async with httpx.AsyncClient() as client:
        response = await client.post(f"{Admin_SERVICE_URL}/service/create_service", json=body)
    return Response(
        content=response.content,
        status_code=response.status_code,
        media_type="application/json"
    )

@router.put("/service_update/{service_id}")
async def update_service(service_id: int, request: Request):
    body = await request.json()
    async with httpx.AsyncClient() as client:
        response = await client.put(f"{Admin_SERVICE_URL}/service/service_update/{service_id}", json=body)
    return Response(
        content=response.content,
        status_code=response.status_code,
        media_type="application/json"
    )

@router.delete("/{service_id}")
async def delete_service(service_id: int, request: Request):
    headers = {}
    auth = request.headers.get("Authorization")
    if auth:
        headers["Authorization"] = auth
    async with httpx.AsyncClient() as client:
        response = await client.delete(f"{Admin_SERVICE_URL}/service/{service_id}", headers=headers)
    return Response(
        content=response.content,
        status_code=response.status_code,
        media_type="application/json"
    )