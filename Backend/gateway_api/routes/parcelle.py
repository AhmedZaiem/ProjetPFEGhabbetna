from fastapi import APIRouter,Request,Response
import httpx
from fastapi.responses import JSONResponse
import json

router = APIRouter()

Auth_SERVICE_URL = "http://localhost:8002"

@router.post("/")
async def create_parcelle(request: Request):
    body = await request.json()
    async with httpx.AsyncClient() as client:
        response = await client.post(f"{Auth_SERVICE_URL}/parcelles/", json=body)
    return Response(
        content=response.content,
        status_code=response.status_code,
        media_type="application/json"
    )

@router.get("/")
async def get_parcelles(request: Request):
    headers = {}

    auth = request.headers.get("Authorization")
    if auth:
        headers["Authorization"] = auth

    async with httpx.AsyncClient() as client:
        response = await client.get(f"{Auth_SERVICE_URL}/parcelles/",headers=headers)
    return Response(
        content=response.content,
        status_code=response.status_code,
        media_type="application/json"
    )

@router.get("/non_occupied_parcelles")
async def get_non_patrolled_parcelles(request: Request):
    headers = {}

    auth = request.headers.get("Authorization")
    if auth:
        headers["Authorization"] = auth

    async with httpx.AsyncClient() as client:
        response = await client.get(f"{Auth_SERVICE_URL}/parcelles/non_occupied_parcelles", headers=headers)
    return Response(
        content=response.content,
        status_code=response.status_code,
        media_type="application/json"
    )

@router.get("/{parcelle_id}")
async def get_parcelle(parcelle_id: int, request: Request):
    headers = {}

    auth = request.headers.get("Authorization")
    if auth:
        headers["Authorization"] = auth

    async with httpx.AsyncClient() as client:
        response = await client.get(f"{Auth_SERVICE_URL}/parcelles/{parcelle_id}", headers=headers)
    return Response(
        content=response.content,
        status_code=response.status_code,
        media_type="application/json"
    )

@router.delete("/{parcelle_id}")
async def delete_parcelle(parcelle_id: int, request: Request):
    headers = {}

    auth = request.headers.get("Authorization")
    if auth:
        headers["Authorization"] = auth

    async with httpx.AsyncClient() as client:
        response = await client.delete(f"{Auth_SERVICE_URL}/parcelles/{parcelle_id}", headers=headers)
    return Response(
        content=response.content,
        status_code=response.status_code,
        media_type="application/json"
    )

@router.post("/{parcelle_id}/assign-agent/{user_id}")
async def assign_agent(request: Request,parcelle_id:int,user_id:int):
    headers = {}

    auth = request.headers.get("Authorization")
    if auth:
        headers["Authorization"] = auth
    async with httpx.AsyncClient() as client:
        response = await client.post(f"{Auth_SERVICE_URL}/parcelles/{parcelle_id}/assign-agent/{user_id}")
    return Response(
        content=response.content,
        status_code=response.status_code,
        media_type="application/json"
    )

