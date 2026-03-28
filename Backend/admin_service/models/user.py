import datetime
from sqlalchemy import Column, Integer, String , Boolean ,ForeignKey, DateTime
from db.database import Base
from sqlalchemy.orm import relationship

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    firstname = Column(String, index=True)
    lastname = Column(String, index=True)
    cin = Column(String, unique=True)
    username = Column(String, unique=True, index=True)
    email = Column(String, unique=True, index=True)
    password_hash = Column(String, nullable=True)
    age = Column(Integer,nullable=False)
    region = Column(String, nullable=False)
    role_id = Column(Integer, ForeignKey("roles.id"), nullable=False)
    role = relationship("Role", back_populates="users")

    supervised_forests = relationship("Forest", back_populates="supervisor")
    parcelle = relationship("Parcelle", back_populates="agent", uselist=False)

    is_verified = Column(Boolean, default=False, nullable=False)
    is_blocked = Column(Boolean, default=False, nullable=False)

    created_at = Column(DateTime, default=datetime.datetime.utcnow)

    class Config:
        orm_mode = True