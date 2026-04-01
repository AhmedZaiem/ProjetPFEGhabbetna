from typing import List

from db.database import get_db
from models.incident import Incident
from models.status_enum import Status
from sqlalchemy.orm import Session
from shapely.geometry import Point
from geoalchemy2.shape import from_shape


def create_incident(db: Session, incident_data):
    point = from_shape(
        Point(incident_data.longitude, incident_data.latitude),
        srid=4326
    )

    new_incident = Incident(
        description=incident_data.description,
        type=incident_data.type,
        region=incident_data.region,
        location=incident_data.location,
        image_url=incident_data.image_url,
        user_id=incident_data.user_id,
        forest_id=incident_data.forest_id,
        coords=point
    )
    db.add(new_incident)
    db.commit()
    db.refresh(new_incident)
    return {
        "id": new_incident.id,
        "description": new_incident.description,
        "type": new_incident.type,
        "region": new_incident.region,
        "location": new_incident.location,
        "image_url": new_incident.image_url,
        "user_id": new_incident.user_id,
        "status": new_incident.status,
        "created_at": new_incident.created_at.isoformat(),
        "forest_id": new_incident.forest_id
    }

def get_all_incidents(db: Session) -> List[Incident]:
    return db.query(Incident).all()

def get_incidents_by_user(db: Session, user_id:int) -> List[Incident]:
    return db.query(Incident).filter(Incident.user_id == user_id).all()

def get_incidents_by_forest_ids(db: Session, forest_ids: list[int]):
    return db.query(Incident).filter(
        Incident.forest_id.in_(forest_ids)
    ).all()


def verify_incident(db: Session, incident_id: int, new_status: Status):
    incident = db.query(Incident).filter(Incident.id == incident_id).first()
    if not incident:
        return None

    incident.status = new_status
    db.commit()
    db.refresh(incident)

    return {
        "id": incident.id,
        "description": incident.description,
        "type": incident.type,
        "region": incident.region,
        "location": incident.location,
        "image_url": incident.image_url,
        "user_id": incident.user_id,
        "status": incident.status.value,
        "created_at": incident.created_at.isoformat(),
        "forest_id": incident.forest_id
    }