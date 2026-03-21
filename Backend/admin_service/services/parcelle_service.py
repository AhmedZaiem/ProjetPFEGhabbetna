from models.forest import Forest
from services.forest_service import calculate_area_hectares
from sqlalchemy.orm import Session
from models.parcelle import Parcelle
from schemas.parcelle_schema import ParcelleCreate, Coordinates
from shapely.geometry import Polygon
from geoalchemy2.shape import from_shape, to_shape
from typing import List
from sqlalchemy import func

def create_parcelle(db: Session, parcelle_in: ParcelleCreate) -> Parcelle:
    coords = [(p.lng, p.lat) for p in parcelle_in.boundary]
    if coords[0] != coords[-1]:
        coords.append(coords[0])
    geom = from_shape(Polygon(coords), srid=4326)

    outside_forest_id = find_forest_for_parcelle(db, geom)
    if not outside_forest_id:
        raise ValueError("Parcelle boundary must be within an existing forest")
    
    if parcell_overlap(db, geom):
        raise ValueError("Parcelle boundary overlaps with an existing parcelle")

    parcelle = Parcelle(
        name=parcelle_in.name,
        area_hectares=calculate_area_hectares(geom),
        boundary=geom,
        forest_id=outside_forest_id
    )
    db.add(parcelle)
    db.commit()
    db.refresh(parcelle)
    return parcelle


def convert_parcelle_boundary(parcelle: Parcelle) -> List[Coordinates]:
    polygon = to_shape(parcelle.boundary)
    return [Coordinates(lat=lat, lng=lng) for lng, lat in polygon.exterior.coords]

def get_all_parcelles(db: Session) -> List[Parcelle]:
    return db.query(Parcelle).all()

def get_parcelle_by_id(db: Session, parcelle_id: int) -> Parcelle | None:
    return db.query(Parcelle).get(parcelle_id)

def get_non_occupied_parcelles(db: Session) -> Parcelle | None:
    return db.query(Parcelle).filter(Parcelle.agent_id==None).all()

def delete_parcelle(db: Session, parcelle_id: int) -> bool:
    parcelle = db.query(Parcelle).get(parcelle_id)
    if not parcelle:
        return False
    db.delete(parcelle)
    db.commit()
    return True

def find_forest_for_parcelle(db: Session, parcelle_boundary_geom) -> int | None:
    parcel_polygon = to_shape(parcelle_boundary_geom)
    forests = db.query(Forest).all()
    for forest in forests:
        forest_polygon = to_shape(forest.boundary)
        if forest_polygon.contains(parcel_polygon):
            return forest.id
    return None

def parcell_overlap(db: Session, polygon):
    existing = db.query(Parcelle).filter(
        func.ST_Overlaps(Parcelle.boundary, polygon) |
        func.ST_Within(polygon , Parcelle.boundary) |
        func.ST_Equals(Parcelle.boundary, polygon)
    ).first()
    return existing is not None

def assign_agent(db: Session, agent_id:int,parcelle:Parcelle):
    parcelle.agent_id = agent_id
    db.commit()   
    db.refresh(parcelle) 
    return True

def get_parcelle_by_agent_id(db: Session, user_id: int):
    return db.query(Parcelle).filter(Parcelle.agent_id == user_id).first()