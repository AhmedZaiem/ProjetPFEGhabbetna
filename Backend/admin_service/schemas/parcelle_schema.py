from pydantic import BaseModel, Field
from typing import Optional, List

class Coordinates(BaseModel):
    lng: float
    lat: float

class ParcelleCreate(BaseModel):
    name: str = Field(min_length=3, max_length=100)
    boundary: List[Coordinates]
    region: str

class ParcelleUpdate(BaseModel):
    name: Optional[str] = Field(None, min_length=3, max_length=100)
    boundary: Optional[List[Coordinates]]
    region: Optional[str]

class ParcelleOut(BaseModel):
    id: int
    name: str
    area_hectares: float
    forest_id: int
    boundary: List[Coordinates]
    agent_id : int | None=None
    region: str

    class Config:
        orm_mode = True
    