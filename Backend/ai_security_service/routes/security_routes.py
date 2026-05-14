from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from db.db import get_db
from models.security_event import SecurityEvent

router = APIRouter(prefix="/security", tags=["Security"])

@router.get("/failed-logins")
def get_failed_logins(db: Session = Depends(get_db)):
    events = db.query(SecurityEvent).filter(SecurityEvent.event_type == "FAILED_LOGIN").order_by(SecurityEvent.timestamp.desc()).limit(10).all()
    return events