from fastapi import APIRouter,Request,Response
import httpx
from fastapi.responses import JSONResponse
import json

router = APIRouter()

Auth_SERVICE_URL = "http://localhost:8002"

@router.post("/")
async def create_forest(request: Request):
    body = await request.json()
    async with httpx.AsyncClient() as client:
        response = await client.post(f"{Auth_SERVICE_URL}/forest/", json=body)
    return Response(
        content=response.content,
        status_code=response.status_code,
        media_type="application/json"
    )

@router.get("/")
async def get_forests(request: Request):
    headers = {}

    auth = request.headers.get("Authorization")
    if auth:
        headers["Authorization"] = auth

    async with httpx.AsyncClient() as client:
        response = await client.get(f"{Auth_SERVICE_URL}/forest/",headers=headers)
    return Response(
        content=response.content,
        status_code=response.status_code,
        media_type="application/json"
    )

@router.get("/non_occupied_forests")
async def get_non_supervised_forests(request: Request):
    headers = {}

    auth = request.headers.get("Authorization")
    if auth:
        headers["Authorization"] = auth

    async with httpx.AsyncClient() as client:
        response = await client.get(f"{Auth_SERVICE_URL}/forest/non_occupied_forests", headers=headers)
    return Response(
        content=response.content,
        status_code=response.status_code,
        media_type="application/json"
    )

@router.get("/{forest_id}")
async def get_forest(forest_id: int, request: Request):
    headers = {}

    auth = request.headers.get("Authorization")
    if auth:
        headers["Authorization"] = auth

    async with httpx.AsyncClient() as client:
        response = await client.get(f"{Auth_SERVICE_URL}/forest/{forest_id}", headers=headers)
    return Response(
        content=response.content,
        status_code=response.status_code,
        media_type="application/json"
    )

@router.delete("/{forest_id}")
async def delete_forest(forest_id: int, request: Request):
    headers = {}

    auth = request.headers.get("Authorization")
    if auth:
        headers["Authorization"] = auth

    async with httpx.AsyncClient() as client:
        response = await client.delete(f"{Auth_SERVICE_URL}/forest/{forest_id}", headers=headers)
    return Response(
        content=response.content,
        status_code=response.status_code,
        media_type="application/json"
    )

@router.post("/{forest_id}/assign-supervisor/{user_id}")
async def assign_supervisor(request: Request,forest_id:int,user_id:int):
    headers = {}

    auth = request.headers.get("Authorization")
    if auth:
        headers["Authorization"] = auth
    async with httpx.AsyncClient() as client:
        response = await client.post(f"{Auth_SERVICE_URL}/forest/{forest_id}/assign-supervisor/{user_id}")
    return Response(
        content=response.content,
        status_code=response.status_code,
        media_type="application/json"
    )


