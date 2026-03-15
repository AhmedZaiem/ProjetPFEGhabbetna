from sqlalchemy import Column, Integer, String , Boolean 
from db.database import Base
from sqlalchemy.orm import relationship

class Role(Base):
    __tablename__ = "roles"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, unique=True, index=True)

    users = relationship("User", back_populates="role")

    class Config:
        orm_mode = True