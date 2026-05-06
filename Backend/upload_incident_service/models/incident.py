from sqlalchemy import Column, Integer, String, DateTime,Enum,Text
from sqlalchemy.sql import func
from geoalchemy2 import Geometry
from db.database import Base
from models.status_enum import Status

class Incident(Base):
    __tablename__ = "incidents"

    id = Column(Integer, primary_key=True, index=True)
    description = Column(String, nullable=False)
    type = Column(String, nullable=False)
    region = Column(String, nullable=False)
    location = Column(String, nullable=False, default="ras jabel")
    image_url = Column(String, nullable=False)
    status = Column(Enum(Status), default=Status.pending)
    comment = Column(Text, nullable=True)

    coords = Column(Geometry(geometry_type="POINT",srid=4326),nullable=False)

    created_at = Column(DateTime, nullable=False, server_default=func.now())
    expires_at = Column(DateTime, nullable=False)

    user_id = Column(Integer)
    user_email = Column(String)
    forest_id = Column(Integer, nullable=False)
    forest_name = Column(String, nullable=False)

    class config:
        orm_mode = True