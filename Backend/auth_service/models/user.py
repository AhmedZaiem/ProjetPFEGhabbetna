from sqlalchemy import Column, Integer, String , Boolean ,ForeignKey
from db.database import Base
from sqlalchemy.orm import relationship

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    username = Column(String, unique=True, index=True)
    email = Column(String, unique=True, index=True)
    password_hash = Column(String, nullable=True)
    age = Column(Integer,nullable=False)

    role = relationship("Role", back_populates="users")
    role_id = Column(Integer, ForeignKey("roles.id"), nullable=False)
    
    is_verified = Column(Boolean, default=False, nullable=False)
    is_blocked = Column(Boolean, default=False, nullable=False)
    activation_token = Column(String, unique=True, index=True, nullable=True)

    class config:
        orm_mode = True