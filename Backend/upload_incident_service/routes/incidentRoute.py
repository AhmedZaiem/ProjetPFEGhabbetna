from fastapi import APIRouter, Depends, HTTPException, UploadFile, File,Form
from sqlalchemy.orm import Session
from db.database import get_db
from schemas.incidentSchema import IncidentCreate
from services.IncidentServices import create_incident
from core.security import get_current_user
import os
import uuid


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
