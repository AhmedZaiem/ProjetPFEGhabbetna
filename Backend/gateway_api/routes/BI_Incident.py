from fastapi import APIRouter, Request
import httpx
from fastapi.responses import Response, JSONResponse
import os

router = APIRouter()

BI_SERVICE_URL = os.getenv("BI_INCIDENT_SERVICE_URL", "http://localhost:8004")

@router.get("/over-time")
async def incidents_over_time():
    custom_timeout = httpx.Timeout(30.0, connect=None)
    async with httpx.AsyncClient(timeout=custom_timeout) as client:
        response = await client.get(f"{BI_SERVICE_URL}/bi_incidents/over-time")

    return JSONResponse(
        status_code=response.status_code,
        content=response.json()
    )


@router.get("/by-status")
async def incidents_by_status():
    custom_timeout = httpx.Timeout(30.0, connect=None)
    async with httpx.AsyncClient(timeout=custom_timeout) as client:
        response = await client.get(f"{BI_SERVICE_URL}/bi_incidents/by-status")

    return JSONResponse(
        status_code=response.status_code,
        content=response.json()
    )


@router.get("/by-region")
async def incidents_by_region():
    custom_timeout = httpx.Timeout(30.0, connect=None)
    async with httpx.AsyncClient(timeout=custom_timeout) as client:
        response = await client.get(f"{BI_SERVICE_URL}/bi_incidents/by-region")

    return JSONResponse(
        status_code=response.status_code,
        content=response.json()
    )

@router.get("/top-forests")
async def top_forests():
    custom_timeout = httpx.Timeout(30.0, connect=None)
    async with httpx.AsyncClient(timeout=custom_timeout) as client:
        response = await client.get(f"{BI_SERVICE_URL}/bi_incidents/top-forests")

    return JSONResponse(
        status_code=response.status_code,
        content=response.json()
    )


@router.get("/top-agents")
async def top_agents():
    custom_timeout = httpx.Timeout(30.0, connect=None)
    async with httpx.AsyncClient(timeout=custom_timeout) as client:
        response = await client.get(f"{BI_SERVICE_URL}/bi_incidents/top-agents")

    return JSONResponse(
        status_code=response.status_code,
        content=response.json()
    )

# AGENT OVER TIME
@router.get("/agent/{agent_id}/over-time")
async def agent_over_time(agent_id: int):
    async with httpx.AsyncClient() as client:
        response = await client.get(
            f"{BI_SERVICE_URL}/bi_incidents/agent/{agent_id}/over-time"
        )

    return JSONResponse(
        status_code=response.status_code,
        content=response.json()
    )


# AGENT BY STATUS
@router.get("/agent/{agent_id}/by-status")
async def agent_by_status(agent_id: int):
    async with httpx.AsyncClient() as client:
        response = await client.get(
            f"{BI_SERVICE_URL}/bi_incidents/agent/{agent_id}/by-status"
        )

    return JSONResponse(
        status_code=response.status_code,
        content=response.json()
    )