from fastapi import APIRouter,Request,Response
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
