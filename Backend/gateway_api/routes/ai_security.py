from fastapi import APIRouter, Request
import httpx
from fastapi.responses import Response, JSONResponse
import os

router = APIRouter()

BI_SERVICE_URL = os.getenv("AI_SECURITY_SERVICE_URL", "http://localhost:8006")

@router.get("/failed-logins")
async def get_failed_logins():
    async with httpx.AsyncClient() as client:
        response = await client.get(f"{BI_SERVICE_URL}/security/failed-logins")

    return JSONResponse(
        status_code=response.status_code,
        content=response.json()
    )