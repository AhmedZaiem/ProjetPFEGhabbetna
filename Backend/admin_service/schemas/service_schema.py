from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime


class ServiceCreate(BaseModel):
    name: str = Field(min_length=2, max_length=100)
    type: str = Field(min_length=2, max_length=50)
    description: Optional[str] = Field(None, max_length=250)
    user_id: int


class ServiceUpdate(BaseModel):
    name: Optional[str] = Field(None, min_length=2, max_length=100)
    type: Optional[str] = Field(None, min_length=2, max_length=50)
    description: Optional[str] = Field(None, max_length=250)


class ServiceOut(BaseModel):
    id: int
    name: str
    type: str
    description: Optional[str] = None
    user_id: int
    created_at: datetime

    class Config:
        orm_mode = True