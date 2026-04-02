from typing import List

from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, Form, Query
from sqlalchemy.orm import Session
from db.database import get_db
from schemas.incidentSchema import IncidentCreate, VerifyIncidentBody
from services.IncidentServices import create_incident,get_all_incidents, get_incidents_by_forest_ids,get_incidents_by_user,verify_incident
from models.status_enum import Status
from core.security import get_current_user
import os
import uuid
from geoalchemy2.shape import to_shape
from shapely.geometry import Point


router = APIRouter(prefix="/incidents", tags=["Incidents"])

UPLOAD_FOLDER = "uploads/incidents"
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

@router.post("/add")
def create_incident_route(
    description: str = Form(...),
    type: str = Form(...),
    location: str = Form(...),
    region: str = Form(...),
    image: UploadFile = File(...),
    latitude: str = Form(...),
    longitude: str = Form(...),
    forest_id: int = Form(...),
    db: Session = Depends(get_db),
    current_user_id= Depends(get_current_user)
):
    
    print("Received:", description, type, location, region, latitude, longitude)

    try:
        lat = float(latitude.replace(',', '.'))
        lon = float(longitude.replace(',', '.'))
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Invalid latitude/longitude: {e}")

    ext=image.filename.split(".")[-1]
    filename = f"{uuid.uuid4()}.{ext}"
    file_path = f"{UPLOAD_FOLDER}/{filename}"

    with open(file_path, "wb") as f:
        f.write(image.file.read())

    incident_data = IncidentCreate(
        description=description,
        type=type,
        location=location,
        region=region,
        image_url=file_path,
        latitude=lat,
        longitude=lon,
        user_id=current_user_id,
        forest_id=forest_id
    )

    return create_incident(db, incident_data)

@router.get("/")
def read_all_incidents(db: Session = Depends(get_db)):
    incidents = get_all_incidents(db)
    result = []
    for i in incidents:
        point : Point = to_shape(i.coords)
        result.append({
            "id": i.id,
            "description": i.description,
            "type": i.type,
            "location": i.location,
            "region": i.region,
            "image_url": i.image_url,
            "latitude": point.y,
            "longitude": point.x,
            "user_id": i.user_id,
            "forest_id": i.forest_id,
            "status": i.status.value if i.status else None
        })
    return result

@router.get("/user/{user_id}")
def read_incidents_by_user(user_id: int, db: Session = Depends(get_db)):
    incidents = get_incidents_by_user(db, user_id)
    result = []
    for i in incidents:
        point : Point = to_shape(i.coords)
        result.append({
            "id": i.id,
            "description": i.description,
            "type": i.type,
            "location": i.location,
            "region": i.region,
            "image_url": i.image_url,
            "latitude": point.y,
            "longitude": point.x,
            "user_id": i.user_id,
            "forest_id": i.forest_id,
            "status": i.status.value if i.status else None
        })
    return result

@router.get("/forests")
def get_forest_incidents(forest_ids: list[int]=Query(...), db: Session = Depends(get_db)):
    incidents = get_incidents_by_forest_ids(db, forest_ids)
    result = []
    for i in incidents:
        point : Point = to_shape(i.coords)
        result.append({
            "id": i.id,
            "description": i.description,
            "type": i.type,
            "location": i.location,
            "region": i.region,
            "image_url": i.image_url,
            "latitude": point.y,
            "longitude": point.x,
            "user_id": i.user_id,
            "forest_id": i.forest_id,
            "status": i.status.value if i.status else None
        })
    return result

@router.patch("/verify/{incident_id}")
def verify_incident_route(incident_id: int, body:VerifyIncidentBody, db: Session = Depends(get_db)):
    status = body.status
    updated_incident = verify_incident(db, incident_id, status)
    if not updated_incident:
        raise HTTPException(status_code=404, detail="Incident not found")
    return updated_incident
    

