from sqlalchemy import Column, Integer, String, DateTime
from sqlalchemy.sql import func
from geoalchemy2 import Geometry
from db.database import Base

class Incident(Base):
    __tablename__ = "incidents"

    id = Column(Integer, primary_key=True, index=True)
    description = Column(String, nullable=False)
    type = Column(String, nullable=False)
    region = Column(String, nullable=False)
    location = Column(String, nullable=False, default="ras jabel")
    image_url = Column(String, nullable=False)

    coords = Column(Geometry(geometry_type="POINT",srid=4326),nullable=False)

    created_at = Column(DateTime, nullable=False, server_default=func.now())

    user_id = Column(Integer)

    class config:
        orm_mode = True