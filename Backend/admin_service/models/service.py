import datetime
from sqlalchemy import Column, Integer, String, Boolean, ForeignKey, DateTime
from db.database import Base
from sqlalchemy.orm import relationship

class Service(Base):
    __tablename__ = "services"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, unique=True, index=True)
    type = Column(String, index=True)
    description = Column(String, nullable=True)


    created_at = Column(DateTime, default=datetime.datetime.utcnow)

    class Config:
        orm_mode = True