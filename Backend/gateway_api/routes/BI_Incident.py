from fastapi import APIRouter, Request
import httpx
from fastapi.responses import Response, JSONResponse

router = APIRouter()

BI_SERVICE_URL = "http://localhost:8004"

@router.get("/over-time")
async def incidents_over_time():
    async with httpx.AsyncClient() as client:
        response = await client.get(f"{BI_SERVICE_URL}/bi_incidents/over-time")

    return JSONResponse(
        status_code=response.status_code,
        content=response.json()
    )


@router.get("/by-status")
async def incidents_by_status():
    async with httpx.AsyncClient() as client:
        response = await client.get(f"{BI_SERVICE_URL}/bi_incidents/by-status")

    return JSONResponse(
        status_code=response.status_code,
        content=response.json()
    )


@router.get("/by-region")
async def incidents_by_region():
    async with httpx.AsyncClient() as client:
        response = await client.get(f"{BI_SERVICE_URL}/bi_incidents/by-region")

    return JSONResponse(
        status_code=response.status_code,
        content=response.json()
    )