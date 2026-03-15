import datetime
from sqlalchemy import Column, Integer, String, Float, ForeignKey,DateTime
from sqlalchemy.orm import relationship
from geoalchemy2 import Geometry
from db.database import Base

class Parcelle(Base):
    __tablename__ = "parcelles"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    area_hectares = Column(Float)
    boundary = Column(Geometry(geometry_type='POLYGON', srid=4326))

    forest_id = Column(Integer,ForeignKey("forests.id"), nullable=False)
    forest = relationship("Forest", back_populates="parcelles")

    agent_id = Column(Integer, ForeignKey("users.id"), nullable=True, unique=True, default=None)
    agent = relationship("User", back_populates="parcelle", uselist=False)
    
    created_at = Column(DateTime, default=datetime.datetime.utcnow)
    class Config:
        orm_mode = True