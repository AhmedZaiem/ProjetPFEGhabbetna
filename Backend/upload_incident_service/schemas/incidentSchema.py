from pydantic import BaseModel, Field

class IncidentCreate(BaseModel):
    description: str
    type: str
    location: str
    region: str
    image_url: str

    latitude: float
    longitude: float

    user_id: int = Field(default=None)

