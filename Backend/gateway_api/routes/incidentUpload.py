from fastapi import APIRouter,Request,Response,Query
import httpx

router = APIRouter()

upload_incident_URL="http://localhost:8003"

@router.post("/add")
async def create_incident(request: Request):
    form = await request.form()

    forest_id = form.get("forest_id")
    if forest_id is None:
        return Response(
            content='{"detail": "forest_id is missing"}',
            status_code=400,
            media_type="application/json"
        )
    data = {
        "description": form.get("description"),
        "type": form.get("type"),
        "location": form.get("location"),
        "region": form.get("region"),
        "latitude": form.get("latitude"),
        "longitude": form.get("longitude"),
        "forest_id": str(forest_id),
    }
    files = {"image": (form["image"].filename, await form["image"].read(), form["image"].content_type)}
    
    headers = {
        "Authorization": request.headers.get("Authorization")
    }

    async with httpx.AsyncClient() as client:
        response = await client.post(f"{upload_incident_URL}/incidents/add", data=data, files=files, headers=headers)

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
    


@router.post("/verify")
async def verify_incident(request: Request):
    data = await request.json()
    incident_id = data.get("incident_id")
    status = data.get("status") 

    if not incident_id or not status:
        return Response(
            content='{"detail": "incident_id or status missing"}',
            status_code=400,
            media_type="application/json"
        )

    headers = {"Authorization": request.headers.get("Authorization")}
    async with httpx.AsyncClient() as client:
        response = await client.post(
            f"{upload_incident_URL}/incidents/verify",
            json={"incident_id": incident_id, "status": status},
            headers=headers
        )

    return Response(
        content=response.content,
        status_code=response.status_code,
        media_type="application/json"
    )
