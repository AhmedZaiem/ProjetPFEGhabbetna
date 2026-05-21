from sqlalchemy import Column, Integer, String, DateTime, Enum, Text
from sqlalchemy.sql import func
from db.database import Base
from models.status_enum import Status


class Incident(Base):
    __tablename__ = "bi_incidents"

    id = Column(Integer, primary_key=True)

    incident_id = Column(Integer, unique=True, index=True)

    user_id = Column(Integer)
    user_email = Column(String)

    forest_id = Column(Integer, nullable=False)
    forest_name = Column(String, nullable=False)

    status = Column(Enum(Status), default=Status.pending)

    type = Column(String, nullable=False)
    region = Column(String, nullable=False)

    comment = Column(Text, nullable=True)

    created_at = Column(DateTime, nullable=False, server_default=func.now())