from sqlalchemy import Column, Integer, String, DateTime, Enum, Text
from sqlalchemy.sql import func
from geoalchemy2 import Geometry
from db.database import Base
from models.status_enum import Status



class Incident(Base):
    __tablename__ = "bi_incidents"

    id = Column(Integer, primary_key=True)
    incident_id = Column(Integer, unique=True, index=True)

    user_id = Column(Integer)
    user_email = Column(String)

    forest_id = Column(Integer)
    forest_name = Column(String)

    status = Column(String)
    type = Column(String)
    region = Column(String)
    comment = Column(Text)

    created_at = Column(DateTime)