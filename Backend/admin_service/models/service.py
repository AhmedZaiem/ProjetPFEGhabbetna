import datetime
from sqlalchemy import Column, Integer, String, Boolean, ForeignKey, DateTime
from db.database import Base
from sqlalchemy.orm import relationship

class Service(Base):
    __tablename__ = "services"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, unique=True, index=True)
    type = Column(String, unique=True, index=True)
    description = Column(String, nullable=True)

    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    user = relationship("User", back_populates="services")

    created_at = Column(DateTime, default=datetime.datetime.utcnow)

    class Config:
        orm_mode = True