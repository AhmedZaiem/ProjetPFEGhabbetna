
import datetime

from .risk_level_enum import RiskLevel
from sqlalchemy import Column, Integer, String, Float, Enum, DateTime,ForeignKey
from geoalchemy2 import Geometry
from db.database import Base
from sqlalchemy.orm import relationship

class Forest(Base):
    __tablename__ = "forests"

    id = Column(Integer, primary_key=True, index=True)

    name = Column(String, nullable=False)
    description = Column(String)
    area_hectares = Column(Float)
    boundary = Column(Geometry(geometry_type='POLYGON', srid=4326))
    risk_level = Column(Enum(RiskLevel), default=RiskLevel.no_data)
    created_at = Column(DateTime, default=datetime.datetime.utcnow)
    region = Column(String, nullable=True)
    supervisor_id = Column(Integer, ForeignKey("users.id"), nullable=True, default=None)
    supervisor = relationship("User", back_populates="supervised_forests", foreign_keys=[supervisor_id])

    parcelles = relationship("Parcelle", back_populates="forest", cascade="all, delete")

    class Config:
        orm_mode = True