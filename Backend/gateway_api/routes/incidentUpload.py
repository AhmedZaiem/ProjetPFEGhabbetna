from fastapi import APIRouter,Request,Response,Query,Body
import httpx
import os


router = APIRouter()

upload_incident_URL=os.getenv("UPLOAD_INCIDENT_SERVICE_URL","http://localhost:8003")

@router.post("/add")
async def create_incident(request: Request):
    headers = {
        "Authorization": request.headers.get("Authorization")
    }

    body = await request.body()

    content_type = request.headers.get("content-type")

    async with httpx.AsyncClient() as client:
        response = await client.post(
            f"{upload_incident_URL}/incidents/add",
            content=body,
            headers={
                "Authorization": headers["Authorization"],
                "Content-Type": content_type
            }
        )

    return Response(
        content=response.content,
        status_code=response.status_code,
        media_type="application/json"
    )

@router.get("/")
async def get_incidents(request: Request):
    headers = {}

    auth = request.headers.get("Authorization")
    if auth:
        headers["Authorization"] = auth

    async with httpx.AsyncClient() as client:
        response = await client.get(f"{upload_incident_URL}/incidents/", headers=headers)
    return Response(
        content=response.content,
        status_code=response.status_code,
        media_type="application/json"
    )

@router.get("/user/{user_id}")
async def get_incidents_by_user_id(request: Request, user_id: int):
    headers = {}

    auth = request.headers.get("Authorization")
    if auth:
        headers["Authorization"] = auth
    async with httpx.AsyncClient() as client:
        response = await client.get(f"{upload_incident_URL}/incidents/user/{user_id}", headers=headers)
    return Response(
        content=response.content,
        status_code=response.status_code,
        media_type="application/json"
    )

@router.get("/forests")
async def get_incidents_by_forest_ids(request: Request, forest_ids: list[int] = Query(...)):
    headers = {}

    auth = request.headers.get("Authorization")
    if auth:
        headers["Authorization"] = auth
    async with httpx.AsyncClient() as client:
        response = await client.get(f"{upload_incident_URL}/incidents/forests", params={"forest_ids": forest_ids}, headers=headers)
    return Response(
        content=response.content,
        status_code=response.status_code,
        media_type="application/json"
    )
    


@router.patch("/verify/{incident_id}")
async def verify_incident(request: Request, incident_id: int):
    data = await request.json()
    status = data.get("status") 
    comment = data.get("comment")
    headers = {}

    if not incident_id or not status or comment is None:
        return Response(
            content='{"detail": "incident_id, status, or comment missing"}',
            status_code=400,
            media_type="application/json"
        )

    auth = request.headers.get("Authorization")
    if auth:
        headers["Authorization"] = auth
    async with httpx.AsyncClient() as client:
        response = await client.patch(
            f"{upload_incident_URL}/incidents/verify/{incident_id}",
            json={"incident_id": incident_id, "status": status, "comment": comment},
            headers=headers

        )

    return Response(
        content=response.content,
        status_code=response.status_code,
        media_type="application/json"
    )

    


