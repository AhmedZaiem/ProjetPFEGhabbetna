from pydantic import BaseModel, Field
from models.status_enum import Status

class IncidentCreate(BaseModel):
    description: str
    type: str
    location: str
    region: str
    image_url: str

    latitude: float
    longitude: float
    forest_id: int
    user_id: int = Field(default=None)

class VerifyIncidentBody(BaseModel):
    status: Status




