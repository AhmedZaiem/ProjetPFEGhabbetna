from pydantic import BaseModel, Field, validator
from typing import Optional, List

class Coordinates(BaseModel):
    lng: float
    lat: float

class ForestCreate(BaseModel):
    name: str = Field(min_length=3, max_length=100)
    description: Optional[str] = Field(None, max_length=500)
    region: str
    boundary: List[Coordinates]


class ForestUpdate(BaseModel):
    name: Optional[str] = Field(None, min_length=3, max_length=100)
    description: Optional[str] = Field(None, max_length=500)
    region: Optional[str]
    boundary: Optional[List[Coordinates]]

class ForestOut(BaseModel):
    id: int
    name: str
    description: Optional[str]
    region: str
    area_hectares: float
    risk_level: str
    boundary: List[Coordinates]
    supervisor_id : int | None=None

    class Config:
        orm_mode = True

    @validator('risk_level', pre=True, always=True)
    def enum_to_str(cls, v):
        return str(v) if v is not None else None
    