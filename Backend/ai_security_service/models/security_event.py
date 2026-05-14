import datetime

from sqlalchemy import Column, Integer, String, Float, Enum, DateTime,ForeignKey
from db.db import Base

class SecurityEvent(Base):
    __tablename__ = "security_events"

    id = Column(Integer, primary_key=True, index=True)
    event_type = Column(String, nullable=False)
    attack_type = Column(String, nullable=False)
    email= Column(String, nullable=False)
    summary = Column(String)
    recommendation = Column(String)
    Risk_level = Column(String)
    timestamp = Column(DateTime, default=datetime.datetime.utcnow)
    attempts= Column(Integer, default=1)
    ip_address = Column(String, nullable=True)

    class Config:
        orm_mode = True
