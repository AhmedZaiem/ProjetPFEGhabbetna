from db.database import get_db
from models.incident import Incident
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
        "latitude": incident_data.latitude,
        "longitude": incident_data.longitude
    }